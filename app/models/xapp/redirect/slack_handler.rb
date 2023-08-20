module Xapp
  class Redirect < ApplicationRecord
    class SlackHandler
      def self.handle(redirect)
        token_info = Slack::UserAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot.find_or_create_by!(
          external_id: token_info['bot_user_id'],
          external_type: 'Bot',
          provider: 'Slack',
          external_data: token_info,
          account__company: Account::Current.company
        )

        @token = Ext::Token.create!(
          authorizer: @bot,
          provider: 'Slack',
          scope: token_info['scope'],
          access_token: token_info['access_token']
        )

        @bot.audit!
      end
    end
  end
end
