require_relative '../test_helper'
require 'squad'

class EventTest < Minitest::Test

  def test_it_sets_the_template_path
    expected_path = Pathname.new(__dir__) + '../..' + 'views' + 'event' + 'team_join'
    assert_equal expected_path.to_s, Event::TeamJoin.new('fakedata').template_path.to_s
  end
end
