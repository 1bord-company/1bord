module Xapp
  class Redirect < ApplicationRecord
    class JiraHandler
      def self.handle(redirect)
        token_info = Jira::UserAccessTokenClient.create(code: redirect.params['code'])

        @token = Sync::Token.create!(
          authorizer: Account::Current.user,
          provider: 'Jira',
          scope: token_info['scope'],
          token: token_info['access_token'],
          expires_at: Time.current + token_info['expires_in'].to_i.seconds
        )
      end
    end
  end
end
