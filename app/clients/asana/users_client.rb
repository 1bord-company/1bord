require 'net/http'

module Asana
  class UsersClient
    def self.index(token, workspace_id) = new(token).index(workspace_id)

    def initialize(token) = @token = token

    def index(workspace_id)
      uri = URI.parse "https://app.asana.com/api/1.0/workspaces/#{workspace_id}/users"
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end
  end
end
