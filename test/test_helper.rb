require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'operationcode_bot'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'rack/test'

require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

ENV['SLACK_TOKEN'] = 'test_token'
ENV['SLACK_CLIENT_ID'] = 'test_client_id'
ENV['SLACK_CLIENT_SECRET'] = 'test_client_id'
ENV['AIRTABLE_API_KEY'] = 'FAKEAIRTABLEKEY'
ENV['AIRTABLE_MENTORSHIP_SQUADS_KEY'] = 'FAKEMENTORSHIPSQUADSKEY'
ENV['INVITE_USER'] = 'true'
ENV['SLACK_CHANNEL_1ST_SQUAD'] = '1STSQUADID'
