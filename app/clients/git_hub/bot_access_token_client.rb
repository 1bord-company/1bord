require 'jwt'

class GitHub::BotAccessTokenClient < AccessTokenClient::Base
  BASE_URL = 'https://api.github.com'.freeze

  def self.create(installation_id:)
    new(installation_id).create
  end

  def initialize(installation_id)
    @installation_id = installation_id
  end

  def create
    json_response = super
    {
      'access_token' => json_response['token'],
      'scope' => json_response['permissions'],
      'expires_at' => json_response['expires_at']
    }
  end

  private

  def data = {}
  def token_path = "app/installations/#{@installation_id}/access_tokens"

  def headers = {
    'Accept' => 'application/vnd.github+json',
    'Authorization' => "Bearer #{jwt}",
    'X-GitHub-Api-Version' => '2022-11-28'
  }

  def jwt = JWT.encode(
    { iat: Time.now.to_i - 60,
      exp: Time.now.to_i + (10 * 60),
      iss: creds.id },
    OpenSSL::PKey::RSA.new(creds.private_key),
    'RS256'
  )
end


