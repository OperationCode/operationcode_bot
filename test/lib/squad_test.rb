require 'squad'
require 'test/unit'
require "mocha/test_unit"

class SquadTest < Test::Unit::TestCase
  def test_it_returns_the_channel_id_of_a_squad
    ENV.expects(:fetch).with('SLACK_CHANNEL_1ST_SQUAD').twice.returns('1234')
    assert_equal '1234', Squad.channel_id_for(:'1st')
    assert_equal '1234', Squad.channel_id_for('1st')
  end
end
