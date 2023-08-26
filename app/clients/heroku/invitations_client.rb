module Heroku
  class InvitationsClient < ResourceClient
    def self.index(token, team_id) = new(token).index(team_id)
    def index(team_id) = get("teams/#{team_id}/invitations")
  end
end
