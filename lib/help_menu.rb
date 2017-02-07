require 'operationcode/slack'

class HelpMenu
  def self.items
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def self.generate_interactive_message
    Operationcode::Slack::Im::Interactive.new(text: 'Please click on a topic', id: 'help_menu', actions: ::HelpMenu.items.collect(&:help_action))
  end

  def self.text
    template = File.read(template_path + class_to_filename)
    ERB.new(template).result(binding)
  end

  class << self
    private

    def template_path
      Pathname.new(__dir__) + '..' + 'views' + name.to_s.underscore + '..'
    end

    def class_to_filename
      "#{name.to_s.demodulize.underscore.downcase}_message.txt.erb"
    end
  end
end
