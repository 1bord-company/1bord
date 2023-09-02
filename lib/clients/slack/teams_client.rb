module Slack
  class TeamsClient < ResourceClient
    def self.show(token, team_id) = new(token).show(team_id)
    def show(team_id) = get("team.info?team=#{team_id}")
  end
end
