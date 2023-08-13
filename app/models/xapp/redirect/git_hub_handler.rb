module Xapp
  class Redirect < ApplicationRecord
    class GitHubHandler
      def self.handle(redirect)
        token_info = GitHub::UserAccessTokenClient.create(code: redirect.params['code'])

        @token = Sync::Token.create!(
          authorizer: Account::Current.user,
          provider: 'GitHub',
          scope: token_info['scope'],
          token: token_info['access_token']
        )

        return if redirect.params['installation_id'].blank?

        @bot = Xapp::Bot.find_or_create_by!(
          redirect: redirect,
          external_id: redirect.params['installation_id'],
          provider: 'GitHub'
        )

        @bot.sync__token!
        @bot.external_data!
      end
    end
  end
end
