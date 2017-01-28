class ButtonPress::SlackHelp < ButtonPress
  def self.help_action
    {name: :slack_help, text: ':slack: Slack', value: :slack_help}
  end
end
