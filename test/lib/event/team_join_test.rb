require 'event/team_join'
require 'test/unit'
require "mocha/test_unit"

class Event::TeamJoinTest < Test::Unit::TestCase
  def setup
    Event::TeamJoin.any_instance.stubs(:user_exists?).returns(nil)
  end

  def test_it_is_an_object
    assert_instance_of Event::TeamJoin, Event::TeamJoin.new(mock_team_join_event)
  end

  def test_it_sends_a_message_to_the_user_if_an_env_var_is_set
    @user = mock
    @user.stubs(:name).returns('FAKE.USERNAME')
    mock_im = mock
    template = File.read('views/event/team_join/welcome_message.txt.erb')
    mock_im.stubs(:deliver).with(ERB.new(template).result(binding))

    ENV['DEV_MODE'] = 'false'
    assert_equal 'false', ENV['DEV_MODE']
    Operationcode::Slack::Im.expects(:new).with(user: '@FAKE.USERNAME').returns(mock_im)

    Event::TeamJoin.new(mock_team_join_event).process

    ENV['DEV_MODE'] = 'true'
    assert_equal 'true', ENV['DEV_MODE']
    Operationcode::Slack::Im.expects(:new).with(user: '@rickr').returns(mock_im)

    Event::TeamJoin.new(mock_team_join_event).process
  end

  def mock_team_join_event
    {
      'token' => 'FAKETOKEN',
      'type' => 'team_join',
      'event' => {
      'user' => {
          'id' =>'FAKEUSERID',
          'name' =>'FAKE.USERNAME',
          'real_name' => 'FAKE NAME',
          'profile' => {
            'first_name' => 'FAKEFIRSTNAME',
            'last_name' => 'FAKELASTNAME'
          }
        }
      }
    }
  end
end
