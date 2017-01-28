class ButtonPress
  attr_reader :response

  def initialize(data)
    @data = data
    @user = data['user']
    @action = data['actions'].first
    @response = nil
  end
end
