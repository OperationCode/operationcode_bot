class ButtonPress
  attr_reader :response

  def initialize(data)
    @data = data
    @user = data['user']
    @action = data['actions'].first
    @response = nil
  end

  def self.help_action
    nil
  end

  def self.show_in_help_menu?
    help_action
  end

  def template_path
    Pathname.new(__dir__) + '..' + 'views' + self.class.name.to_s.underscore + '..'
  end

  def class_to_filename
    "#{self.class.name.to_s.demodulize.underscore.downcase}_message.txt.erb"
  end

  def render_button_template
    template = File.read(template_path + class_to_filename)
    ERB.new(template).result(binding)
  end

  def process
    Operationcode::Slack::Im.new(user: @user['id'], text: render_button_template)
    nil
  end
end
