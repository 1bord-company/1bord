require 'net/http'

class Jira::AccessibleResourcesClient
  def self.index(token) = new(token).index
  def initialize(token) = @token = token

  def index
    # Set the API endpoint URL
    url = URI.parse('https://api.atlassian.com/oauth/token/accessible-resources')

    # Create the HTTP request
    request = Net::HTTP::Get.new(url)
    request['Authorization'] = "Bearer #{@token}"

    # Make the API request
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Parse the response as JSON
    JSON.parse(response.body)
  end
end
