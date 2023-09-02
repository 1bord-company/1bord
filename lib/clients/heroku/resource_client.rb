module Heroku
  class ResourceClient < ResourceClient::Base
    BASE_URL = 'https://api.heroku.com'.freeze

    private

    def headers = super.merge(
      'Accept' => 'application/vnd.heroku+json; version=3'
    )
  end
end
