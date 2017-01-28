require 'sinatra'
require 'httparty'
require 'json'
require 'operationcode/airtable'
require 'operationcode/slack'

Dir[File.join(File.dirname(__FILE__), 'lib', '**/*.rb')].sort.each { |file| require file }

set :slack_token, ENV.fetch('SLACK_TOKEN')
set :lock, true

before do
  content_type 'application/json'
end

get '/ping' do
  { success: :ok, data: :pong }.to_json
end

post '/event' do
  event_data = read_post_body
  logger.info "Received Event with data #{event_data}"

  event_type = event_data.has_key?('event') ? event_data['event']['type'] : event_data['type']

  dispatch_event(type: event_type, with_data: event_data, token: event_data['token'])
end

post '/slack/button_press' do
  button_data = JSON.parse params['payload']
  logger.info "Received Button Press with data #{button_data}"

  callback = button_data['callback_id']
  button_press_klass = "ButtonPress::#{callback.classify}".constantize

  button_press = button_press_klass.new(button_data)
  button_press.process
  button_press.response ? button_press.response : halt(200)
end

get '/oauth/redirect' do
  logger.info "OAUTH with code #{params['code']}"
  response = Operationcode::Slack::Api::OauthAccess.post(with_data: { code: params['code'] })
  logger.info "RX #{response}"
  empty_response
end

private

def event_callback(data, token: nil)
  event_data = data['event']
  event_type = event_data['type'].to_sym
  logger.info "Received Event #{event_type}"
  dispatch_event(type: event_type, with_data: event_data, token: data['token'])
end

def url_verification(data, token: nil)
  { challenge: data['challenge'] }.to_json
end

def team_join(data, token: nil)
  logger.info "New member joined: #{data}"

  Event::TeamJoin.new(data, token: token, logger: logger).process

  empty_response
end

def message(data, token: nil)
  logger.info "New message recieved: #{data}"

  if bot_message?(data)
    logger.info 'Skipping bot message'
  else
    Event::Message.new(data, token: token, logger: logger).process
  end

  empty_response
end

def bot_message?(data)
  data['event']['subtype'] == 'bot_message' || data['event']['message']['subtype'] == 'bot_message'
end

def empty_response
  {}.to_json
end

def read_post_body
  request.body.rewind
  JSON.parse request.body.read
end

# Dynamically calls a method of the same name as the +event_type+
# If anything fails we return an empty response
def dispatch_event(type: event_type, with_data: data, token: nil)
  # This wierd Object include check has to do with Ruby's odd main/top level behaviours
  # We are basically just checking that the method was defined in this file
  if(type && Object.private_instance_methods.include?(type.to_sym))
    send(type.to_sym, with_data, token: token)
  else
    logger.info "Did not find a handler for event type '#{type}'"
    empty_response
  end
end
