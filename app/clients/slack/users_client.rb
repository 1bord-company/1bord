module Slack
  class UsersClient < ResourceClient
    def self.index(token) = new(token).index
    def index = get('users.list')
  end
end
