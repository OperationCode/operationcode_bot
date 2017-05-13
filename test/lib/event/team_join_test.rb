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
    welcome_string = "Hi FAKE.USERNAME,\n\nWelcome to Operation Code! I'm a bot designed to help answer questions and get you on your\nway in our community.\n\nOur goal here at Operation Code is to get veterans and their families started on the path to\na career in programming. We do that through providing you with scholarships, mentoring, career\ndevelopment opportunities, conference tickets, and more!\n\nYou're currently in Slack, a chat application that serves as the hub of Operation Code.\nIf you're currently visiting us via your browser Slack provides a stand alone program\nto make staying in touch even more convenient. You can download it here:\nhttps://slack.com/downloads\n\nBelow you'll see a list of topics. You can click on each topic to get more info. If you\nwant to see the topics again just reply to me with any message.\n\nWant to make your first change to a program right now? Click on the 'OpCode Challenge'\nbutton to get instructions on how to make a change to this very bot!\n"
    ENV['PRODUCTION_MODE'] = 'true'
    assert_equal 'true', ENV['PRODUCTION_MODE']
    Operationcode::Slack::Im.expects(:new).with(user: 'FAKEUSERID', text: welcome_string).returns(@mock_im)
    Operationcode::Slack::Im.expects(:new).with(channel: 'G3MD48QTD', text: ':tada: FAKE.USERNAME has joined the Slack team :tada:').returns(@mock_im)

    Event::TeamJoin.new(mock_team_join_event).process

    ENV['PRODUCTION_MODE'] = 'false'
    assert_equal 'false', ENV['PRODUCTION_MODE']
    Operationcode::Slack::Im.expects(:new).with(user: 'U08U56D5K', text: welcome_string).returns(@mock_im)
    Operationcode::Slack::Im.expects(:new).with(channel: 'G3MD48QTD', text: ':tada: FAKE.USERNAME has joined the Slack team :tada:').returns(@mock_im)

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
