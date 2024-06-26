require 'net/http'

module ResourceClient
  class Base
    def get(url)
      uri = URI.parse "#{self.class::BASE_URL}/#{url}"

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri, headers

      @response = http.request request

      JSON.parse response_body
    end

    def initialize(token) = @token = token

    private

    def resource_name = self.class.name.demodulize.underscore.downcase.gsub(/_client/, '')

    def headers = {
      'Authorization' => "Bearer #{@token}"
    }

    def response_body = @response.body
  end
end
