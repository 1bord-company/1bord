require 'net/http'

class Jira::UsersClient
  def self.index(token, resource_id) = new(token, resource_id).index
  def initialize(token, resource_id)
    @token = token
    @resource_id = resource_id
  end

  def index
    # Set the API endpoint URL
    url = URI.parse("https://api.atlassian.com/ex/jira/#{@resource_id}/rest/api/3/users")

    # Create the HTTP request
    request = Net::HTTP::Get.new(url)
    request['Authorization'] = "Bearer #{@token}"

    # Make the API request
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end
end
