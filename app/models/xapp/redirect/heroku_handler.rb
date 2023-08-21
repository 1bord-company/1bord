module Xapp
  class Redirect < ApplicationRecord
    class HerokuHandler
      def self.handle(redirect)
        token_info = Heroku::BotAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot.create_or_find_by! \
          external_id: token_info['user_id'],
          external_type: 'Bot',
          provider: 'Heroku',
          account__company: Account::Current.company

        @token = Ext::Token.create! \
          authorizer: @bot,
          provider: 'Heroku',
          access_token: token_info['access_token'],
          expires_at: Time.current + token_info['expires_in'].to_i.seconds,
          refresh_token: token_info['refresh_token']

        @bot.audit!
      end
    end
  end
end
