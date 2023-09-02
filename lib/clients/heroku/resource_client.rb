module Heroku
  class ResourceClient < ::ResourceClient::Base
    private

    def headers = super.merge(
      'Accept' => 'application/vnd.heroku+json; version=3'
    )
  end
end
