module Xapp
  class Redirect < ApplicationRecord
    class AsanaHandler
      def self.handle(redirect)
        token_info = Asana::BotAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot.create_or_find_by! \
          external_id: "asana-#{Account::Current.company.id}",
          external_type: 'Bot',
          provider: 'Asana',
          account__company: Account::Current.company

        @token = Ext::Token.create! \
          authorizer: @bot,
          provider: 'Asana',
          **token_info.slice(*%w[access_token expires_in refresh_token])

        @bot.audit!
      end
    end
  end
end
