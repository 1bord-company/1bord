require 'net/http'

module Heroku
  class BotAccessTokenClient
    BASE_URL = 'https://id.heroku.com'.freeze

    def self.create(code:) = new(code).create

    def initialize(code) = @code = code

    def create
      data = {
        'grant_type' => 'authorization_code',
        'client_secret' => Rails.application.credentials.providers.heroku
                                .app.client_secret,
        'code' => @code
      }

      url = "#{BASE_URL}/oauth/token"

      uri = URI.parse url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Post.new uri.path
      request.set_form_data data

      response = http.request request

      JSON.parse response.body
    end
  end
end
