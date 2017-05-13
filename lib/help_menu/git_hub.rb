class HelpMenu::GitHub < HelpMenu
  def self.help_action
    { name: :github, text: 'GitHub', value: :github_help }
  end
end
