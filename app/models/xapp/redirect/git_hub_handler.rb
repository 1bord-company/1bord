module Xapp
  class Redirect < ApplicationRecord
    class GitHubHandler
      def self.handle(redirect)
        token_info = GitHub::UserAccessTokenClient.create(code: redirect.params['code'])

        @token = Ext::Token.create!(
          authorizer: Account::Current.user,
          provider: 'GitHub',
          scope: token_info['scope'],
          token: token_info['access_token']
        )

        return if redirect.params['installation_id'].blank?

        @bot = Ext::Bot.find_or_create_by!(
          external_id: redirect.params['installation_id'],
          external_type: 'Installation',
          provider: 'GitHub',
          account__company: Account::Current.company
        )

        @bot.token!
        @bot.external_data!
        @bot.audit!
      end
    end
  end
end
