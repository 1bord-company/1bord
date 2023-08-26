module Asana
  class UsersClient < ResourceClient
    def self.show(token, user_id) = new(token).show(user_id)
    def show(user_id) = get("users/#{user_id}")
  end
end
