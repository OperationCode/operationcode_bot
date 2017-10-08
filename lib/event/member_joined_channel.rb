require 'operationcode/slack'

# Handler for a Member Joined Channel event. When a user joins a Slack channel, we want to:
# * Check what channel is joined, and take additional actions on a per- channel basis as needed

class Event
  class MemberJoinedChannel < Event
    attr_reader :user

    def initialize(data, token: nil, logger: nil)
      super
      @template = File.read(template_path + 'welcome_message.txt.erb')
    end

    def process
      @user = Operationcode::Slack::User.new(@data['event']['user'])
      log "Production mode: #{production_mode?}"
      log "Welcoming mentor #{resolve_user_name}"

      # TODO: only call welcome_mentor if internal mentors channel was joined
      welcome_mentor!
    end

    private

    # Welcome greeting for our Slack internal mentors channel. When a new mentor joins it, we want to:
    # * Post a welcome message
    # * Post a link to the 'Intro to Mentoring' document

    def welcome_mentor!
      im = Operationcode::Slack::Im.new(user: resolve_user_name, text: ERB.new(@template).result(binding))
      im.make_interactive_with!(HelpMenu.generate_interactive_message)
      im.deliver
    end

    def resolve_user_name
      production_mode? ? user.id : 'U08U56D5K'
    end
  end
end
