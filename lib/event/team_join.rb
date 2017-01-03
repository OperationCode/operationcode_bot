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
      log "Welcoming user #{resolve_user_name}"
      Operationcode::Slack::Im.new(user: resolve_user_name).deliver(ERB.new(@template).result(binding))
    end

    private

    def resolve_user_name
      dev_mode? ? '@rickr' : "@#{user.name}"
    end
  end
end
