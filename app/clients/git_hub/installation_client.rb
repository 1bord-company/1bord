require 'jwt'

class GitHub::InstallationClient < ResourceClient::Base
  BASE_URL = 'https://api.github.com'.freeze

  def initialize(installation_id) = @installation_id = installation_id

  def self.show(installation_id) = new(installation_id).show
  def show = get("app/installations/#{@installation_id}")

  private

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

  def creds = Rails.application.credentials.providers.git_hub.app
end
