module Xapp
  class Redirect < ApplicationRecord
    class JiraHandler
      def self.handle(redirect)
        token_info = Jira::UserAccessTokenClient.create(code: redirect.params['code'])

        resources =
          Jira::AccessibleResourcesClient
          .index(token_info['access_token']).map do |resource|
            Ext::Resource.create!(
              name: resource['name'],
              external_id: resource['id'],
              account__company: Account::Current.company,
              external_type: 'Resource',
              external_data: resource,
              provider: 'Jira'
            )
          end

        resources.each do |resource|
          Jira::UsersClient
            .index(token_info['access_token'], resource.external_id).each do |user|
            persona = Ext::Persona.create!(
              name: user['displayName'],
              external_id: user['accountId'],
              external_type: (user['accountType'] == 'app' ? 'Bot' : 'User'),
              account__holder: Account::Current.company,
              external_data: user,
              provider: 'Jira'
            )

            persona.roles.create!(
              resource: resource,
              name: 'Role',
              provider: 'Jira'
            )

            next if persona.name != '1bord Basic'

            @bot = Ext::Bot.create!(
              external_id: persona.external_id,
              external_type: 'Bot',
              provider: 'Jira',
              external_data: persona.external_data,
              account__company: Account::Current.company
            )

            Account::Audit.create! auditor: @bot, auditee: resource
          end
        end

        @token = Ext::Token.create!(
          authorizer: @bot,
          provider: 'Jira',
          scope: token_info['scope'],
          token: token_info['access_token'],
          expires_at: Time.current + token_info['expires_in'].to_i.seconds,
          refresh_token: token_info['refresh_token']
        )
      end
    end
  end
end
