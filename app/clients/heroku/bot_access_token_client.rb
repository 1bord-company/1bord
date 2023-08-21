require 'net/http'

module Heroku
  class BotAccessTokenClient
    BASE_URL = 'https://id.heroku.com'.freeze

    def self.create(code: nil, refresh_token: nil)
      new(code, refresh_token).create
    end

    def initialize(code, refresh_token)
      @code = code
      @refresh_token = refresh_token
    end

    def create
      url = "#{BASE_URL}/oauth/token"

      uri = URI.parse url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Post.new uri.path
      request.set_form_data data

      response = http.request request

      JSON.parse response.body
    end

    private

    def data
      {
        'client_secret' => Rails.application.credentials.providers.heroku
                                .app.client_secret,
      }.tap do |base|
        @code && base.merge!({ 'grant_type' => 'authorization_code',
                              'code' => @code })
        @refresh_token && base.merge!({ 'grant_type' => 'refresh_token',
                                       'refresh_token' => @refresh_token })
        end
      end
  end
end
