require_relative '../../test_helper'
require 'event/team_join'

class Event::TeamJoinTest < Minitest::Test
  def setup
    Event::TeamJoin.any_instance.stubs(:user_exists?).returns(nil)
    @user = mock

    @user.stubs(:name).returns('FAKE.USERNAME')
    @mock_im = mock
    @mock_im.stubs(:deliver)
    @mock_im.stubs(:make_interactive_with!)
  end

  def test_it_is_an_object
    assert_instance_of Event::TeamJoin, Event::TeamJoin.new(mock_team_join_event)
  end

  def test_it_sends_a_message_to_the_user_if_an_env_var_is_set
    ENV['PRODUCTION_MODE'] = 'true'
    assert_equal 'true', ENV['PRODUCTION_MODE']
    Operationcode::Slack::Im.expects(:new).with(user: 'FAKEUSERID').returns(@mock_im)
    Operationcode::Slack::Im.expects(:new).with(channel: 'G3NDEBB45', text: ':tada: FAKE.USERNAME has joined the slack team :tada:').returns(@mock_im)

    Event::TeamJoin.new(mock_team_join_event).process

    ENV['PRODUCTION_MODE'] = 'false'
    assert_equal 'false', ENV['PRODUCTION_MODE']
    Operationcode::Slack::Im.expects(:new).with(user: 'U08U56D5K').returns(@mock_im)
    Operationcode::Slack::Im.expects(:new).with(channel: 'G3NDEBB45', text: ':tada: FAKE.USERNAME has joined the slack team :tada:').returns(@mock_im)

    Event::TeamJoin.new(mock_team_join_event).process
  end

  def test_it_notifies_staff
    Operationcode::Slack::Im.stubs(:new).returns(@mock_im)
    @mock_im.expects(:deliver)

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
