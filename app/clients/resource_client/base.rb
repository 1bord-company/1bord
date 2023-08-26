require 'net/http'

module ResourceClient
  class Base
    def get(url)
      uri = URI.parse "#{self.class::BASE_URL}/#{url}"

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Authorization'] = "Bearer #{@token}"

      response = http.request request

      JSON.parse response.body
    end

    def initialize(token) = @token = token
  end
end
