require 'net/http'

module Asana
  class UsersClient
    def self.show(token, user_id) = new(token).show(user_id)

    def initialize(token) = @token = token

    def show(user_id)
      uri = URI.parse "https://app.asana.com/api/1.0/users/#{user_id}"
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end
  end
end
