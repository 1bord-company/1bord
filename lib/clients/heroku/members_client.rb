module Heroku
  class MembersClient < ResourceClient
    include ::ResourceClient::CompressedResponse

    def self.index(token, team_id) = new(token).index(team_id)
    def index(team_id) = get("teams/#{team_id}/members")
  end
end
