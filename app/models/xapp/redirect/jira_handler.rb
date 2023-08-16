module Xapp
  class Redirect < ApplicationRecord
    class JiraHandler
      def self.handle(redirect)
        token_info = Jira::UserAccessTokenClient.create(code: redirect.params['code'])

        @token = Sync::Token.create!(
          authorizer: Account::Current.user,
          provider: 'Jira',
          scope: token_info['scope'],
          token: token_info['access_token'],
          expires_at: Time.current + token_info['expires_in'].to_i.seconds
        )

        resources =
          Jira::AccessibleResourcesClient.index(@token.token).map do |resource|
            Core::Resource.create!(
              name: resource['name'],
              external_id: resource['id'],
              account__holder: Account::Current.company,
              external_type: 'Resource',
              external_data: resource,
              provider: 'Jira'
            )
          end
      end
    end
  end
end
