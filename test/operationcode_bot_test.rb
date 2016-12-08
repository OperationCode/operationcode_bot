ENV['RACK_ENV'] = 'test'

require 'operationcode_bot'
require 'test/unit'
require 'rack/test'
require "mocha/test_unit"

class OperationcodeBotTest < Test::Unit::TestCase
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

  def test_it_does_something_on_new_user_join
    Operationcode::Airtable.any_instance.stubs(:all).returns([
      Airtable::Record.new(slack_username: 'test1', squad: '1st'),
      Airtable::Record.new(slack_username: 'test2', squad: '2nd'),
      Airtable::Record.new(slack_username: 'test3', squad: '2nd'),
      Airtable::Record.new(slack_username: 'test4', squad: '3rd'),
      Airtable::Record.new(slack_username: 'test5', squad: '3rd')
    ])
    Operationcode::Airtable.any_instance.stubs(:find_by).returns(nil)

    HTTParty.expects(:post)
      .with('https://slack.com/api/channels.invite', body: { token: 'FAKE_TOKEN', user: 'FAKEUSERID', channel: '1STSQUADID' })
      .returns({ok: true}.to_json)

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
