require 'net/http'

module Heroku
  class InvitationsClient
    def self.index(token, team_id) = new(token, team_id).index

    def initialize(token, team_id)
      @token, @team_id = [token, team_id]
    end

    def index
      uri = URI.parse "https://api.heroku.com/teams/#{@team_id}/invitations"
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.path
      request['Accept'] = 'application/vnd.heroku+json; version=3'
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end
  end
end