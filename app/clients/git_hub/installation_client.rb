require 'jwt'

module GitHub
  class InstallationClient < ResourceClient
    def initialize(installation_id) = @installation_id = installation_id

    def self.show(installation_id) = new(installation_id).show
    def show = get("app/installations/#{@installation_id}")

    private

    def headers = super.merge('Authorization' => "Bearer #{jwt}")

    def jwt = JWT.encode(
      { iat: Time.now.to_i - 60,
        exp: Time.now.to_i + (10 * 60),
        iss: creds.id },
      OpenSSL::PKey::RSA.new(creds.private_key),
      'RS256'
    )

    def creds = Rails.application.credentials.providers.git_hub.app
  end
end
