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
      Operationcode::Slack::Im.new(user: resolve_user_name).deliver(ERB.new(@template).result(binding))
    end

    def notify_staff!
      Operationcode::Slack::Api::ChatPostMessage.post(
        with_data: {
          channel: Event::STAFF_NOTIFICATION_CHANNEL,
          text: ":tada: #{@user.name} has joined the slack team :tada:",
          attachments: [
            {
              text: 'Have they been greeted?',
              fallback: 'This is a fallback message',
              callback_id: 'greeted',
              color: '#3AA3E3',
              attachment_type: 'default',
              actions: [
                {
                  name: 'yes',
                  text: 'Yes',
                  type: 'button',
                  value: 'yes',
                  style: 'primary'
                }
              ]
            }
          ]
        })
    end

    def resolve_user_name
      production_mode? ? user.id : 'U08U56D5K'
    end
  end
end
