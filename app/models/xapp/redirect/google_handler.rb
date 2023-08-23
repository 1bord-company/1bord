module Xapp
  class Redirect < ApplicationRecord
    class GoogleHandler
      def self.handle(redirect)
        token_info = Google::BotAccessTokenClient.create(code: redirect.params['code'])
      end
    end
  end
end
