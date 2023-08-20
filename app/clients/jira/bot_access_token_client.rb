require 'net/http'

class Jira::BotAccessTokenClient
  def self.create(code: nil, refresh_token: nil)
    new(code, refresh_token).create
  end

  def initialize(code, refresh_token)
    @code = code
    @refresh_token = refresh_token
  end

  def create
    url = URI.parse('https://auth.atlassian.com/oauth/token')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    headers = {
      'Content-Type' => 'application/json'
    }

    request = Net::HTTP::Post.new(url.path, headers)
    request.set_form_data(data)

    response = http.request(request)

    JSON.parse response.body
  end

  private

  def data
    app_credentials = Rails.application.credentials.providers.jira.app

    {
      'client_id' => app_credentials.client_id,
      'client_secret' => app_credentials.client_secret,
      'redirect_uri' => Rails.application.credentials.host_url + app_credentials.redirect_path,
    }.tap do |base|
      @code && base.merge!({ 'grant_type' => 'authorization_code',
                            'code' => @code })
      @refresh_token && base.merge!({ 'grant_type' => 'refresh_token',
                                     'refresh_token' => @refresh_token })
    end
  end
end
