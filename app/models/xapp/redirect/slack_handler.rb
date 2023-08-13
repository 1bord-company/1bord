module Xapp
  class Redirect < ApplicationRecord
    class SlackHandler
      def self.handle(redirect)
        token_info = Slack::UserAccessTokenClient.create(code: redirect.params['code'])

        @bot = Xapp::Bot.find_or_create_by!(
          redirect: redirect,
          external_id: redirect.params['installation_id'],
          provider: 'Slack'
        )

        @token = Sync::Token.create!(
          authorizer: @bot,
          provider: 'Slack',
          scope: token_info['scope'],
          token: token_info['access_token']
        )
      end
    end
  end
end
