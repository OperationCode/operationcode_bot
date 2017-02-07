require 'operationcode/slack'

# Handler for a Team Join event. When a new user joins Slack we want them to
# * Explain our mentorship program and ask them if they want to join a squad
# * If they respond affirmatively our message handler will:
#   * Be assigned to the least populated mentorship squad
#   * Have their squad and user info added to the Mentorship air table
#   * Be invited to the squad's slack private channel
class Event
  class TeamJoin < Event
    attr_reader :user

    def initialize(data, token: nil, logger: nil)
      super
      @template = File.read(template_path + 'welcome_message.txt.erb')
    end

    def process
      @user = Operationcode::Slack::User.new(@data['event']['user'])
      log "Production mode: #{production_mode?}"
      log "Welcoming user #{resolve_user_name}"

      welcome_user!
      notify_staff!
    end

    private

    def welcome_user!
      im = Operationcode::Slack::Im.new(user: resolve_user_name, text: ERB.new(@template).result(binding))
      im.make_interactive_with!(HelpMenu.generate_interactive_message)
      im.deliver
    end

    def notify_staff!
      im = Operationcode::Slack::Im.new(
        channel: Event::STAFF_NOTIFICATION_CHANNEL,
        text: ":tada: #{@user.name} has joined the slack team :tada:"
      )
      im.make_interactive_with!(
        Operationcode::Slack::Im::Interactive.new(
          text: 'Have they been greeted?',
          id: 'greeted',
          actions: [
            { name: 'yes', text: 'Yes', value: 'yes' }
          ]
        )
      )
      im.deliver
    end

    def resolve_user_name
      production_mode? ? user.id : 'U08U56D5K'
    end
  end
end
