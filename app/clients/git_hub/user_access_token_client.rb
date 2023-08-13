require 'net/http'

class GitHub::UserAccessTokenClient
  def self.create(code:)
    new(code).create
  end

  def initialize(code)
    @code = code
  end

  def create
    url = URI.parse('https://github.com/login/oauth/access_token')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    app_credentials = Rails.application.credentials.providers.git_hub.app

    data = {
      'client_id' => app_credentials.client_id,
      'client_secret' => app_credentials.client_secret,
      'code' => @code,
      'redirect_uri' => Rails.application.credentials.host_url + app_credentials.redirect_path
    }

    request = Net::HTTP::Post.new(url.path)
    request.set_form_data(data)

    response = http.request(request)
    parse_response(response.body)
  end

  private

  def parse_response(response_body)
    response_body.split('&').each_with_object({}) do |param, hash|
      key, value = param.split('=')
      hash[key] = value
    end
  end
end

