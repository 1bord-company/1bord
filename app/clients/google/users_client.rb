require 'net/http'

module Google
  class UsersClient
    def self.index(token) = new(token).index

    def initialize(token) = @token = token

    def index
      uri = URI.parse 'https://admin.googleapis.com/admin/directory/v1/users?customer=my_customer'
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end
  end
end
