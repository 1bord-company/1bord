module Jira
  class BotAccessTokenClient < AccessTokenClient::Base
    BASE_URL = 'https://auth.atlassian.com'.freeze
    TOKEN_PATH = 'oauth/token'.freeze
  end
end
