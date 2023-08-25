module Heroku
  class BotAccessTokenClient < AccessTokenClient::Base
    BASE_URL = 'https://id.heroku.com'.freeze
    TOKEN_PATH = 'oauth/token'.freeze
  end
end
