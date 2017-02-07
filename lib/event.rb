# Base class for events
class Event
  STAFF_NOTIFICATION_CHANNEL = 'G3NDEBB45'.freeze

  def initialize(data, token: nil, logger: nil)
    @data = data
    @token = token
    @logger = logger
  end

  # Make sure we are in dev mode unless explicitly disabled
  def production_mode?
    ENV['PRODUCTION_MODE'] == 'true' ? true : false
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
