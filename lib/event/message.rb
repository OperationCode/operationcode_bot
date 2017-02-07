require 'operationcode/slack'

# Handler for a Team Join event. When a new user joins Slack we want them to
# * Be assigned to the least populated mentorship squad
# * Have their squad and user info added to the Mentorship air table
# * Be invited to the squad's slack private channel
class Event
  class Message < Event
    attr_reader :user

    ACTIONABLE_KEYWORD = 'yes'.freeze

    def initialize(data, token: nil, logger: nil)
      @message = data['event']['text']
      @user = Operationcode::Slack::User.new(data['event']['user'])
      @channel = data['event']['channel']

      super
    end

    def process
      im = Operationcode::Slack::Im.new(
        user: user.id,
        channel: @channel,
        text: "I'm sorry. I don't know how to talk to humans yet. Here's what I do know."
      )
      im.make_interactive_with!(HelpMenu.generate_interactive_message)
      im.deliver
    end

    private

    # The rest of this has to do with actionable items
    # and will be moved over soon
    def user_wants_to_join?
      @data['event']['text'].downcase != 'no'
    end

    def add_user
      if user_exists?
        log "user #{user.name} already exists"
      else
        invite_user_to least_populated_squad
        save_user_to_airtables!
      end
    end

    def user_exists?
      Airtables::MentorshipSquads.user_exists?(user.name)
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
      Airtables::MentorshipSquads.create({ slack_username: user.name, squad: @squad })
    end

    def least_populated_squad
      @squad ||= Airtables::MentorshipSquads.least_populated
    end
  end
end
