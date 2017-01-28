class ButtonPress
  attr_reader :response

  def initialize(data)
    @user = data['user']
    @action = data['actions'].first
    @response = nil
  end
end
