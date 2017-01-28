require 'operationcode/slack'

class HelpMenu
  def self.items
    button_action_items = ObjectSpace.each_object(Class).select { |klass| klass < ButtonPress }
    button_action_items.select { |b| b if b.show_in_help_menu? }
  end

  def self.generate_interactive_message
    Operationcode::Slack::Im::Interactive.new(text: 'Please click on a topic', id: 'help_menu', actions: ::HelpMenu.items.collect(&:help_action))
  end
end
