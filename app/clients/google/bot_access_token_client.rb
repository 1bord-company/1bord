require 'net/http'

module Google
  class BotAccessTokenClient
    BASE_URL = 'https://oauth2.googleapis.com'.freeze

    def self.create(code: nil, refresh_token: nil)
      new(code, refresh_token).create
    end

    def initialize(code, refresh_token)
      @code = code
      @refresh_token = refresh_token
    end

    def create
      url = "#{BASE_URL}/token"

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
      creds = Rails.application.credentials.providers.google.app
      {
        'client_secret' => creds.client_secret,
        'client_id' => creds.client_id,
        'redirect_uri' => Rails.application.credentials.host_url + creds.redirect_path
      }.tap do |base|
        @code && base.merge!({ 'grant_type' => 'authorization_code',
                               'code' => @code })
        @refresh_token && base.merge!({ 'grant_type' => 'refresh_token',
                                        'refresh_token' => @refresh_token })
        end
      end
  end
end
