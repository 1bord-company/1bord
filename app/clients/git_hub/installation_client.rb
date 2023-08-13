require 'jwt'
require 'net/http'

class GitHub::InstallationClient
  BASE_URL = 'https://api.github.com'

  def self.show(installation_id)
    new(installation_id).show
  end

  def initialize(installation_id)
    @installation_id = installation_id
  end

  def show
    creds = Rails.application.credentials
                 .providers.git_hub.app

    jwt = JWT.encode(
      { iat: Time.now.to_i - 60,
        exp: Time.now.to_i + (10 * 60),
        iss: creds.id },
      OpenSSL::PKey::RSA.new(creds.private_key),
      'RS256'
    )

    url = "#{BASE_URL}/app/installations/#{@installation_id}"

    headers = {
      'Accept' => 'application/vnd.github+json',
      'Authorization' => "Bearer #{jwt}",
      'X-GitHub-Api-Version' => '2022-11-28'
    }

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.path, headers)
    response = http.request(request)

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      raise "Error occurred: #{response.code} - #{response.body}"
    end
  end
end
