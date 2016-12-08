module Airtables
  module MentorshipSquads
    TABLE_NAME = 'squads'.freeze
    BASE_ID = ENV.fetch('AIRTABLE_MENTORSHIP_SQUADS_KEY').freeze

    def self.create(record)
      client.create(record)
    end

    def self.least_populated
      client
        .all
        .group_by { |r| r[:squad] }.map { |k, v| [v.length, k] }
        .sort
        .first[1]
        .to_sym
    end

    def self.user_exists?(username)
      client.find_by(slack_username: username)
    end

    def self.client
      Operationcode::Airtable.new(base_id: BASE_ID, table: TABLE_NAME)
    end
  end
end
