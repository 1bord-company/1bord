module Xapp
  class Redirect < ApplicationRecord
    class GitHubHandler
      def self.handle(redirect)

        token_info = GitHub::UserAccessTokenClient.create(code: redirect.params['code'])

        @bot = Xapp::Bot.find_or_create_by!(
          redirect: redirect,
          external_id: redirect.params['installation_id'],
          provider: 'GitHub'
        )

        @token = Sync::Token.create!(
          authorizer: @bot,
          provider: 'GitHub',
          scope: token_info['scope'],
          token: token_info['access_token']
        )
      end
    end
  end
end
