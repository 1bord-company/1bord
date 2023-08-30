module Xapp
  class Redirect < ApplicationRecord
    class GoogleHandler
      def self.handle(redirect)
        token_info = Google::BotAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            external_id: "google-#{Account::Current.company.id}",
            external_type: 'Bot',
            provider: 'Google',
            account__company: Account::Current.company

        @token = Ext::Token
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            authorizer: @bot,
            provider: 'Google',
            **token_info
              .tap { _1['expires_at'] = Time.current + _1['expires_in'].to_i.seconds }
              .slice(*%w[access_token expires_at refresh_token])

        @bot.audit!
      end
    end
  end
end
