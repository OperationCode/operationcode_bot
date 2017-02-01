class HelpMenu::OpcodeChallenge < HelpMenu
  def self.help_action
    { name: :opcode_challenge, text: ':opcode: OpCode Challenge', value: :opcode_challenge }
  end

  def text
    names_file = File.join(File.dirname(__FILE__), '../../opcode_challenge/names.txt')
    @names = File.read(names_file)

    super
  end
end
