require 'net/http'

class GitHub::MembersClient
  def self.index(token, org) = new(token, org).index
  def initialize(token, org)
    @token = token
    @org = org
  end

  def index
    # Set the API endpoint URL
    url = URI.parse("https://api.github.com/orgs/#{@org}/members")

    # Create the HTTP request
    request = Net::HTTP::Get.new(url)
    request['Accept'] = 'application/vnd.github+json'
    request['Authorization'] = "Bearer #{@token}"
    request['X-GitHub-Api-Version'] = '2022-11-28'

    # Make the API request
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Parse the response as JSON
    if response.code.to_i == 200
      JSON.parse(response.body).map do |member|
        {
          'login' => member['login'],
          'id' => member['id'],
          'avatar_url' => member['avatar_url'],
          'data' => member
        }
      end
    else
      puts "Request failed with status code: #{response.code}"
    end
  end
end

