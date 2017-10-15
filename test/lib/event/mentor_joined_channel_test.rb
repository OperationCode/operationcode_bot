require_relative '../../test_helper'
require 'event/mentor_joined_channel'

class Event::MentorJoinedChannelTest < Minitest::Test
  def setup
    Event::MentorJoinedChannel.any_instance.stubs(:user_exists?).returns(nil)
    @user = mock

    @user.stubs(:name).returns('FAKE.USERNAME')
    @mock_im = mock
    @mock_im.stubs(:deliver)
  end

  def test_it_is_an_object
    assert_instance_of Event::MentorJoinedChannel, Event::MentorJoinedChannel.new(mock_mentor_joined_channel_event)
  end

  def test_it_sends_message_to_user_if_env_var_is_set_and_mentors_channel_joined
    ENV['PRODUCTION_MODE'] = 'true'
    assert_equal 'true', ENV['PRODUCTION_MODE']
    Operationcode::Slack::Im.expects(:new).with(has_value('FAKEUSERID')).returns(@mock_im)

    Event::MentorJoinedChannel.new(mock_mentor_joined_channel_event(with_channel: 'G04CRMCT4')).process

    ENV['PRODUCTION_MODE'] = 'false'
    assert_equal 'false', ENV['PRODUCTION_MODE']
    Operationcode::Slack::Im.expects(:new).with(has_value('U08U56D5K')).returns(@mock_im)

    Event::MentorJoinedChannel.new(mock_mentor_joined_channel_event(with_channel: 'G04CRMCT4')).process
  end

  def mock_mentor_joined_channel_event(with_channel: 'CHANNEL ID')
    {
      'token' => 'FAKETOKEN',
      'type' => 'event_callback',
      'event' => {
        'user' => {
          'id' => 'FAKEUSERID',
        },
        'channel' => with_channel
      }
    }
  end
end
