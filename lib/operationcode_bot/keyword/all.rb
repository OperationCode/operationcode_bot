class OperationcodeBot::Menu::Keyword::All < OperationcodeBot::Menu::Keyword
  def self.help_text
    'Display all my known keywords'
  end

  def self.render
    OperationcodeBot::Menu::Keyword.list_help_texts
  end
end
