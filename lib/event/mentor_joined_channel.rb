require 'operationcode/slack'

# Handler for a Member Joined Channel event in the internal mentors channel. When that occurs, we want to:
# * Post a welcome message with useful information

class Event::MentorJoinedChannel < Event
  attr_reader :user

  def initialize(data, token: nil, logger: nil)
    super
    @template = File.read(template_path + 'welcome_message.txt.erb')
  end

  def process
    @user = Operationcode::Slack::User.new(@data['event']['user'])
    log "Production mode: #{production_mode?}"
    log "Welcoming mentor #{resolve_user_name}"

    welcome_mentor!
  end

  private

  def welcome_mentor!
    im = Operationcode::Slack::Im.new(user: resolve_user_name, text: ERB.new(@template).result(binding))
    im.deliver
  end

  def resolve_user_name
    production_mode? ? user.id : 'U08U56D5K'
  end
end