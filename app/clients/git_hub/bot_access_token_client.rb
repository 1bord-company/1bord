require 'jwt'
require 'net/http'

class GitHub::BotAccessTokenClient
  BASE_URL = 'https://api.github.com'.freeze

  def self.create(installation_id:)
    new(installation_id).create
  end

  def initialize(installation_id)
    @installation_id = installation_id
  end

  def create
    creds = Rails.application.credentials
                 .providers.git_hub.app

    jwt = JWT.encode(
      { iat: Time.now.to_i - 60,
        exp: Time.now.to_i + (10 * 60),
        iss: creds.id },
      OpenSSL::PKey::RSA.new(creds.private_key),
      'RS256'
    )

    url = "#{BASE_URL}/app/installations/#{@installation_id}/access_tokens"

    headers = {
      'Accept' => 'application/vnd.github+json',
      'Authorization' => "Bearer #{jwt}",
      'X-GitHub-Api-Version' => '2022-11-28'
    }

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, headers)
    response = http.request(request)

    if response.code.to_i == 201
      json_response = JSON.parse(response.body)
      {
        'token' => json_response['token'],
        'scope' => json_response['permissions'],
        'expires_at' => json_response['expires_at']
      }
    else
      raise "Error occurred: #{response.code} - #{response.body}"
    end
  end
end


