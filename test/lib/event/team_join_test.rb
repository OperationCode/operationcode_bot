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

  def test_it_invites_a_user_to_a_channel_if_an_env_var_is_set
    Airtables::MentorshipSquads.stubs(:least_populated).returns('1st')
    assert_equal ENV['INVITE_USER'], 'true'

    HTTParty.expects(:post)
      .with('https://slack.com/api/channels.invite', body: { token: nil, user: 'FAKEUSERID', channel: '1STSQUADID' })
      .returns({ok: true}.to_json)

    event = Event::TeamJoin.new(mock_team_join_event)
    event.process

    ENV['INVITE_USER'] = 'false'
    refute_equal ENV['INVITE_USER'], 'true'

    event = Event::TeamJoin.new(mock_team_join_event)
    event.process
  end

  def test_it_creates_an_airtable_record
    Airtables::MentorshipSquads.expects(:least_populated).returns('1st')
    Airtables::MentorshipSquads.expects(:create).with(slack_username: 'FAKE.USERNAME', squad: '1st')

    event = Event::TeamJoin.new(mock_team_join_event)
    event.process
  end

  def test_it_doesnt_create_a_record_if_the_slack_username_exists
    Event::TeamJoin.any_instance.stubs(:user_exists?).returns(::Airtable::Record.new(slack_username: 'FAKE_USERNAME'))
    Airtables::MentorshipSquads.expects(:create).never

    event = Event::TeamJoin.new(mock_team_join_event)
    event.process
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
