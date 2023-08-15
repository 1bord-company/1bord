require 'net/http'

class Slack::UserAccessTokenClient
  def self.create(code:)
    new(code).create
  end

  def initialize(code)
    @code = code
  end

  def create
    url = URI.parse('https://slack.com/api/oauth.v2.access')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    app_credentials = Rails.application.credentials.providers.slack.app

    data = {
      'client_id' => app_credentials.client_id,
      'client_secret' => app_credentials.client_secret,
      'code' => @code
    }

    request = Net::HTTP::Post.new(url.path)
    request.set_form_data(data)

    response = http.request(request)

    json = JSON.parse response.body

    {
      'external_id' => json['bot_user_id'],
      'access_token' => json['access_token'],
      'scope' => json['scope'],
      'team' => json['team']
    }
  end
end

