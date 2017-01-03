require 'operationcode/slack'

# Handler for a Team Join event. When a new user joins Slack we want them to
# * Be assigned to the least populated mentorship squad
# * Have their squad and user info added to the Mentorship air table
# * Be invited to the squad's slack private channel
class Event
  class Message < Event
    attr_reader :user

    KEYWORDS = %q(help ruby)
    ACTIONABLE_KEYWORD = 'yes'

    def initialize(data, token: nil, logger: nil)
      @message = data['event']['text']
      @user = Operationcode::Slack::User.new(data['event']['user'])

      super
    end

    def process
      case @message
      when ACTIONABLE_KEYWORD
        add_user
      when KEYWORDS[@message]
        send_message_for @message
      else
        send_message_for :help_menu
      end
    end

    def send_message_for(type)
      puts "Sending message #{type}"
      template = File.read(template_path + "#{type}_message.txt.erb")
      Operationcode::Slack::Im.new(user: resolve_user_name).deliver(ERB.new(template).result(binding))
    end

    private

    def resolve_user_name
      production_mode? ? "@#{user.name}" : '@rickr'
    end


    def user_wants_to_join?
      @data['event']['text'].downcase != 'no'
    end

    def add_user
      if user_exists?
        log "user #{@user.name} already exists"
      else
        invite_user_to least_populated_squad
        save_user_to_airtables!
      end
    end

    def user_exists?
      Airtables::MentorshipSquads.user_exists?(@user.name)
    end

    def invite_user_to(squad)
      channel_id = Squad.channel_id_for squad

      log "Inviting #{user.id} (#{user.name}) to channel #{channel_id} (#{squad})"
      if ENV['INVITE_USER'] == 'true'
        Operationcode::Slack::Api::ChannelsInvite.post(
          with_data: {
            token: @token,
            channel: channel_id,
            user: user.id
          }
        )
      end
    end

    def save_user_to_airtables!
      log "Adding slack username #{user.name} to squad #{@squad} to airtables"
      Airtables::MentorshipSquads.create({slack_username: user.name, squad: @squad})
    end

    def least_populated_squad
      @squad ||= Airtables::MentorshipSquads.least_populated
    end
  end
end
