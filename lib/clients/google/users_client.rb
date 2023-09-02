module Google
  class UsersClient < ResourceClient::Base
    BASE_URL = 'https://admin.googleapis.com'.freeze

    def self.index(token) = new(token).index
    def index = get('admin/directory/v1/users?customer=my_customer')
  end
end
