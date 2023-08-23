module Xapp
  class Redirect < ApplicationRecord
    class GoogleHandler
      def self.handle(redirect)
        token_info = Google::BotAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot.create_or_find_by! \
          external_type: 'Bot',
          provider: 'Google',
          account__company: Account::Current.company

        @token = Ext::Token.create! \
          authorizer: @bot,
          provider: 'Google',
          **token_info.slice(*%w[access_token expires_in refresh_token])
      end
    end
  end
end
