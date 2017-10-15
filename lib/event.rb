# Base class for events
class Event
  COMMUNITY_CHANNEL = 'G3MD48QTD'
  MENTORS_INTERNAL_CHANNEL = 'G04CRMCT4'

  def initialize(data, token: nil, logger: nil)
    @data = data
    @token = token
    @logger = logger
  end

  def template_path
    Pathname.new(__dir__) + '..' + 'views' + self.class.name.to_s.underscore
  end

  private

  # Interface for logging via Sinatra or STDOUT
  #
  # @param message [String] the message to log
  # @param level [Symbol] the level to log at (if logging via Sinatra)
  def log(message, level: :info)
    if @logger
      @logger.send(level, message)
    else
      puts message
    end
  end
end
