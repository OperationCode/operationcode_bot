class Bot::Menu::Keyword::All < Bot::Menu::Keyword
  def self.help_text
    'Display all my known keywords'
  end

  def self.render
    Bot::Menu::Keyword.list_help_texts
  end
end
