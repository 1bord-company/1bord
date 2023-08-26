module Slack
  class UsersClient < ResourceClient::Base
    BASE_URL = 'https://slack.com/api'

    def self.index(token) = new(token).index
    def index = get('users.list')
  end
end
