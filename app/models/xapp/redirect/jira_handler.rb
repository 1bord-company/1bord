module Xapp
  class Redirect < ApplicationRecord
    class JiraHandler
      def self.handle(redirect)
        token_info = Jira::BotAccessTokenClient.create(code: redirect.params['code'])

        resources =
          Jira::AccessibleResourcesClient
          .index(token_info['access_token']).map do |resource|
            Ext::Resource
              .extending(ActiveRecord::CreateOrFindAndUpdateBy)
              .create_or_find_and_update_by! \
                name: resource['name'],
                external_id: resource['id'],
                account__company: Account::Current.company,
                external_type: 'Resource',
                external_data: resource,
                provider: 'Jira'
          end

        resources.each do |resource|
          Jira::UsersClient
            .index(token_info['access_token'], resource.external_id)
            .each do |user|
              if user['displayName'] == '1bord Basic'
                @bot = Ext::Bot
                  .extending(ActiveRecord::CreateOrFindAndUpdateBy)
                  .create_or_find_and_update_by! \
                  name: user['displayName'],
                  external_id: user['accountId'],
                  external_type: 'Bot',
                  provider: 'Jira',
                  external_data: user,
                  account__company: Account::Current.company

                Account::Audit.create! auditor: @bot, auditee: resource
              else
                persona = Ext::Persona
                  .extending(ActiveRecord::CreateOrFindAndUpdateBy)
                  .create_or_find_and_update_by! \
                  name: user['displayName'],
                  external_id: user['accountId'],
                  external_type: (user['accountType'] == 'app' ? 'Bot' : 'User'),
                  account__holder: Account::Current.company,
                  external_data: user,
                  provider: 'Jira'

                persona.roles
                  .extending(ActiveRecord::CreateOrFindAndUpdateBy)
                  .create_or_find_and_update_by! \
                  resource: resource,
                  name: 'Role',
                  provider: 'Jira'
              end
            end
        end

        @token = Ext::Token.create!(
          authorizer: @bot,
          provider: 'Jira',
          scope: token_info['scope'],
          access_token: token_info['access_token'],
          expires_at: Time.current + token_info['expires_in'].to_i.seconds,
          refresh_token: token_info['refresh_token']
        )
      end
    end
  end
end
