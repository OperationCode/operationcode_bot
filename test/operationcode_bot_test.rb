require_relative './test_helper'

class OperationcodeBotTest < Minitest::Test
  include Rack::Test::Methods

  SLACK_OAUTH_ACCESS_PATH = 'https://slack.com/api/oauth.access'
  SLACK_USERS_INFO_PATH = 'https://slack.com/api/users.info'

  def app
    Sinatra::Application
  end

  def test_it_can_verify_its_url
    post '/event', { type: 'url_verification', challenge: 'yeEDKbeqUN9bAGUeP7sRDqTvF1CAlLdJjyNl20QAStFGXPDCNak6' }.to_json
    assert last_response.ok?
    assert_equal '{"challenge":"yeEDKbeqUN9bAGUeP7sRDqTvF1CAlLdJjyNl20QAStFGXPDCNak6"}', last_response.body
  end

  def test_it_responds_to_ping
    get '/ping'
    assert last_response.ok?
    assert_equal ({ success: :ok, data: :pong }.to_json), last_response.body
  end

  def test_it_can_oauth
    client_id = ENV['SLACK_CLIENT_ID']
    client_secret = ENV['SLACK_CLIENT_SECRET']
    oauth_code = '3570763187.114951093348.e285c6000c'

    assert client_id
    assert client_secret

    HTTParty.expects(:post).with(SLACK_OAUTH_ACCESS_PATH, body: { client_id: client_id, client_secret: client_secret, code: oauth_code })

    get '/oauth/redirect', { code: oauth_code, state: nil }
    assert last_response.ok?
  end

  def test_it_handles_unknown_payloads
    post '/event', { type: 'this_is_a_type_that_will_never_be_defined' }.to_json
    assert last_response.ok?
    assert_equal '{}', last_response.body

    post '/event', {}.to_json
    assert last_response.ok?
    assert_equal '{}', last_response.body
  end

  def test_it_only_runs_methods_defined
    Sinatra::Application.any_instance.expects(:self).never
    post '/event', { type: 'self' }.to_json
    assert_equal '{}', last_response.body

    Sinatra::Application.any_instance.expects(:inspect).never
    post '/event', { type: 'inspect' }.to_json
    assert_equal '{}', last_response.body
  end

  def test_it_welcomes_the_user_on_new_user_join
    Operationcode::Airtable.any_instance.stubs(:find_by).returns(nil)
    template = File.read('views/event/team_join/welcome_message.txt.erb')
    @user = mock
    @user.stubs(:name).returns('FAKEUSERNAME')
    ENV['PRODUCTION_MODE'] = 'true'

    mock_im = mock
    mock_im.expects(:deliver).with(ERB.new(template).result(binding))

    Operationcode::Slack::User.any_instance.stubs(:name).returns('FAKEUSERNAME')
    Operationcode::Slack::Api::ChatPostMessage.expects(:post).with(
      with_data: {
        channel: Event::STAFF_NOTIFICATION_CHANNEL, 
        text: ':tada: FAKEUSERNAME has joined the slack team :tada:', 
        attachments: [
          {
            text: 'Have they been greeted?',
            fallback: 'This is a fallback message',
            callback_id: 'greeted',
            color: '#3AA3E3',
            attachment_type: 'default',
            actions: [
              {name: 'yes', text: 'Yes', type: 'button', value: 'yes', style: 'primary' }
            ]
          }]
      }
    )
    Operationcode::Slack::Im.expects(:new).with(user: 'FAKEUSERID').returns(mock_im)

    team_join_data = {
      token: 'FAKE_TOKEN',
      team_id: 'TXXXXXXXX',
      api_app_id: 'AXXXXXXXXX',
      event: {
        type: 'team_join',
        event_ts: '1234567890.123456',
        user: {
          id: "FAKEUSERID",
          name: "FAKEUSERNAME"
        },
      },
      type: 'event_callback',
      authed_users: [
        'UXXXXXXX1',
        'UXXXXXXX2'
      ]
    }

    post '/event', team_join_data.to_json
    assert last_response.ok?
  end
end
