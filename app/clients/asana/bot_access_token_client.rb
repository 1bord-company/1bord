module Asana
  class BotAccessTokenClient < AccessTokenClient::Base
    BASE_URL = 'https://app.asana.com'.freeze
    TOKEN_PATH = '-/oauth_token'.freeze
  end
end
