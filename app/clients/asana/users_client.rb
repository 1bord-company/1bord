module Asana
  class UsersClient < ResourceClient::Base
    BASE_URL = 'https://app.asana.com/api/1.0'.freeze

    def self.show(token, user_id) = new(token).show(user_id)

    def show(user_id) = get("users/#{user_id}")
  end
end
