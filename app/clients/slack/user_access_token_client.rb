module Slack
  class UserAccessTokenClient < AccessTokenClient::Base
    BASE_URL = 'https://slack.com'.freeze
    TOKEN_PATH = 'api/oauth.v2.access'.freeze
  end
end
