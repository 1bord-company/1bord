require 'net/http'

class Slack::UsersClient
  def self.index(token) = new(token).index
  def initialize(token) = @token = token

  def index
    # Set the API endpoint URL
    url = URI.parse('https://slack.com/api/users.list')

    # Create the HTTP request
    request = Net::HTTP::Get.new(url)
    request['Authorization'] = "Bearer #{@token}"

    # Make the API request
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(request)
    end

    json = JSON.parse response.body
    # Parse the response as JSON
    if response.code.to_i == 200 && json['ok']
      json['members'].map do |member|
        {
          'name' => member['name'],
          'id' => member['id'],
          'data' => member
        }
      end
    else
      puts "Request failed with status code: #{response.code}"
    end
  end
end
