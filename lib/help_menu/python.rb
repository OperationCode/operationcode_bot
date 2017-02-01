class HelpMenu::Python < HelpMenu
  def self.help_action
    { name: :python, text: ':python: Python', value: :python_help }
  end
end
