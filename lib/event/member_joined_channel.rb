require 'operationcode/slack'

# Handler for a Member Joined Channel event. When a user joins a Slack channel, we want to:
# * Check what channel is joined, and take additional actions on a per- channel basis as needed

class Event
  class MemberJoinedChannel < Event
    attr_reader :user

    def initialize(data, token: nil, logger: nil)
      super
      @channel = data['event']['channel']

    # TODO: May need better way to conditionally assign template, if we have other channels that need welcome messages
      if @channel == Event::MENTORS_INTERNAL_CHANNEL
        @template = File.read(template_path + 'mentor_welcome_message.txt.erb')
      end
    end

    def process
      @user = Operationcode::Slack::User.new(@data['event']['user'])
      log "Production mode: #{production_mode?}"
      log "Welcoming mentor #{resolve_user_name}"

      if @channel == Event::MENTORS_INTERNAL_CHANNEL
        welcome_mentor!
      end
    end

    private

    # Posts a welcome message when new mentors join our Slack internal mentors channel
    def welcome_mentor!
      im = Operationcode::Slack::Im.new(user: resolve_user_name, text: ERB.new(@template).result(binding))
      im.deliver
    end

    def resolve_user_name
      production_mode? ? user.id : 'U08U56D5K'
    end
  end
end
