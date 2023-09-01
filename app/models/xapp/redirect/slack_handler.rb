module Xapp
  class Redirect < ApplicationRecord
    class SlackHandler
      def self.handle(redirect)
        token_info = Slack::BotAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            external_id: token_info['bot_user_id'],
            external_type: 'Bot',
            provider: 'Slack',
            external_data: token_info,
            account__company: Account::Current.company

        @token = Ext::Token
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            authorizer: @bot,
            provider: 'Slack',
            scope: token_info['scope'],
            access_token: token_info['access_token']

        @bot.audit!
      end
    end
  end
end
