module Xapp
  class Redirect < ApplicationRecord
    class GitHubHandler
      def self.handle(redirect)
        return if redirect.params['installation_id'].blank?

        @bot = Ext::Bot.find_or_create_by!(
          external_id: redirect.params['installation_id'],
          external_type: 'Installation',
          provider: 'GitHub',
          account__company: Account::Current.company
        )

        @bot.audit!
      end
    end
  end
end
