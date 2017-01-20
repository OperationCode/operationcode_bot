require 'active_support/all'
require 'pathname'

class Bot::Menu
  def initialize(message)
    @message = message.downcase
  end


  def message
    if valid_keyword?
      render(@message)
    else
      render('help')
    end
  end

  def render(keyword)
    keyword_klass = "Bot::Menu::Keyword::#{keyword.classify}".constantize
    keyword_klass.render
  end

  def valid_keyword?
    Bot::Menu::Keyword.all.include? @message
  end
end

