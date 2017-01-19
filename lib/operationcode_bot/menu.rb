class OperationcodeBot::Menu
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
    keyword_klass = "OperationcodeBot::Menu::Keyword::#{keyword.classify}".constantize
    keyword_klass.render
  end

  def valid_keyword?
    OperationcodeBot::Menu::Keyword.all.include? @message
  end
end

require_relative './keyword'
require 'active_support/all'
require 'pathname'


#puts OperationcodeBot::Menu.new('ruby').message
#puts
#puts OperationcodeBot::Menu.new('slack').message
#puts
#puts OperationcodeBot::Menu.new('all').message
#puts
#puts OperationcodeBot::Menu.new('blah').message
