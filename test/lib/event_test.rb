require 'squad'
require 'test/unit'
require "mocha/test_unit"

class EventTest < Test::Unit::TestCase
  def test_it_checks_for_dev_mode
    ENV['DEV_MODE'] = 'true'
    assert Event.new('fake data').dev_mode?

    ENV['DEV_MODE'] = 'false'
    refute Event.new('fake data').dev_mode?
  end

  def test_it_sets_the_template_path
    expected_path = Pathname.new(__dir__) + '../..' + 'views' + 'event' + 'team_join'
    assert_equal expected_path.to_s, Event::TeamJoin.new('fakedata').template_path.to_s
  end
end
