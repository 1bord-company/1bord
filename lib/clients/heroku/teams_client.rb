module Heroku
  class TeamsClient < ResourceClient
    include ::ResourceClient::CompressedResponse

    def self.index(token) = new(token).index
    def index = get('teams')
  end
end
