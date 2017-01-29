class HelpMenu::Slack < HelpMenu
  def self.help_action
    { name: :slack, text: ':slack: Slack', value: :slack_help }
  end
end
