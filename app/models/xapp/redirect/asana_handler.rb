module Xapp
  class Redirect < ApplicationRecord
    class AsanaHandler
      def self.handle(redirect)
        token_info = Asana::BotAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            external_id: "asana-#{Account::Current.company.id}",
            external_type: 'Bot',
            provider: 'Asana',
            account__company: Account::Current.company

        @token = Ext::Token
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            authorizer: @bot,
            provider: 'Asana',
            **token_info
              .tap { _1['expires_at'] = Time.current + _1['expires_in'].to_i.seconds }
              .slice(*%w[access_token expires_at refresh_token])

        @bot.audit!
      end
    end
  end
end
