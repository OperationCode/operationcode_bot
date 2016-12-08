module Squad
  def self.channel_id_for(squad)
    ENV.fetch("SLACK_CHANNEL_#{squad.upcase}_SQUAD")
  end
end
