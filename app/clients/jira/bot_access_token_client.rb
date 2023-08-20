require 'net/http'

class Jira::BotAccessTokenClient
  def self.create(code:) = new(code).create

  def initialize(code) = @code = code

  def create
    url = URI.parse('https://auth.atlassian.com/oauth/token')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    headers = {
      'Content-Type' => 'application/json'
    }

    app_credentials = Rails.application.credentials.providers.jira.app

    data = {
      'grant_type' => 'authorization_code',
      'client_id' => app_credentials.client_id,
      'client_secret' => app_credentials.client_secret,
      'redirect_uri' => Rails.application.credentials.host_url + app_credentials.redirect_path,
      'code' => @code
    }

    request = Net::HTTP::Post.new(url.path, headers)
    request.set_form_data(data)

    response = http.request(request)

    JSON.parse response.body
  end
end
