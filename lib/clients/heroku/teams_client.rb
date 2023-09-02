module Heroku
  class TeamsClient < ResourceClient
    include ::ResourceClient::CompressedResponse
  end
end
