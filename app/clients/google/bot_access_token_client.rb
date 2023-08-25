module Google
  class BotAccessTokenClient < AccessTokenClient::Base
    BASE_URL = 'https://oauth2.googleapis.com'.freeze
    TOKEN_PATH = 'token'.freeze
  end
end
