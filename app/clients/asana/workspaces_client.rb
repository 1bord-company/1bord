require 'net/http'

module Asana
  class WorkspacesClient
    def self.index(token) = new(token).index

    def initialize(token) = @token = token

    def index
      uri = URI.parse 'https://app.asana.com/api/1.0/workspaces'
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end
  end
end
