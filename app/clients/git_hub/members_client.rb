require 'net/http'

class GitHub::MembersClient
  def initialize(token) = @token = token

  def self.index(token, org) = new(token).index(org)
  def index(org)
    # Set the API endpoint URL
    url = URI.parse("https://api.github.com/orgs/#{org}/members")

    # Create the HTTP request
    request = Net::HTTP::Get.new url, headers

    # Make the API request
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Parse the response as JSON
    JSON.parse response.body
  end

  private

  def headers = {
    'Accept' => 'application/vnd.github+json',
    'Authorization' => "Bearer #{@token}",
    'X-GitHub-Api-Version' => '2022-11-28'
  }
end
