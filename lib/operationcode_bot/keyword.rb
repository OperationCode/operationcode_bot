#module OperationcodeBot; end
#class OperationcodeBot::Menu; end
#class OperationcodeBot::Menu::Keyword; end

Dir["./keyword/*.rb"].each {|file| require file }

class OperationcodeBot::Menu::Keyword
  def self.template_path
    Pathname.new(__dir__) + '..' + '..' + 'views' + self.name.to_s.underscore + '..'
  end

  def self.descendents
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def self.all
    descendents.collect { |d| class_to_keyword(d) }
  end

  def self.class_to_keyword(name)
    name.to_s.demodulize.underscore.humanize.downcase
  end

  def self.help_text
    'No help text has been defined'
  end

  def self.render
    template = File.read(template_path + "#{class_to_keyword(self)}_message.txt.erb")
    ERB.new(template).result(binding)
  end

  def self.list_help_texts
    descendents.select{ |k| k.show_in_help? }
      .map{ |k| "#{class_to_keyword(k)} - #{k.help_text}" }
      .sort
      .join("\n")
  end

  def self.show_in_help?
    true
  end
end
