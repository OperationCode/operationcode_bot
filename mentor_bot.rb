require 'sinatra'
require 'httparty'
require 'json'

before do
  content_type 'application/json'
end

post '/event' do
  handle_request_with params
end

get '/event' do
  handle_request_with params
end

def handle_request_with(params)
  puts "Received Event with params #{params}"
  { challenge: params[:challenge] }.to_json
end
