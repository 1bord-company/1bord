require 'net/http'

module Heroku
  class TeamsClient
    def self.index(token) = new(token).index

    def initialize(token) = @token = token

    def index
      uri = URI.parse 'https://api.heroku.com/teams/'
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.path)
      request['Accept'] = 'application/vnd.heroku+json; version=3'
      request['Authorization'] = "Bearer #{@token}"

      response = http.request(request)

      decompressed_response =
        Zlib::GzipReader.new(StringIO.new(response.body)).read
      JSON.parse decompressed_response
    end
  end
end
