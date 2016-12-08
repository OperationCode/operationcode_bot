# Base class for events
class Event
  def initialize(data, token: nil, logger: nil)
    @data = data
    @token = token
    @logger = logger
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
