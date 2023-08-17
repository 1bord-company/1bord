module Xapp
  class Redirect < ApplicationRecord
    class GitHubHandler
      def self.handle(redirect)
        token_info = GitHub::UserAccessTokenClient.create(code: redirect.params['code'])

        @token = Sync::Token.create!(
          authorizer: Account::Current.user,
          provider: 'GitHub',
          scope: token_info['scope'],
          token: token_info['access_token']
        )

        return if redirect.params['installation_id'].blank?

        @bot = Core::Bot.find_or_create_by!(
          external_id: redirect.params['installation_id'],
          external_type: 'Installation',
          provider: 'GitHub',
          account__holder: Account::Current.company
        )

        @bot.sync__token!
        @bot.external_data!

        account = @bot.external_data['account']

        org = Core::Resource.create!(
          name: account['login'],
          external_id: account['id'],
          provider: 'GitHub',
          external_data: account,
          external_type: account['type'],
          account__holder: @bot.account__company
        )

        members =
          GitHub::MembersClient
          .index @bot.sync__token.token, account['login']

        members.each do |member|
          persona = Core::Persona.create!(
            name: member['login'],
            external_id: member['id'],
            provider: 'GitHub',
            external_data: member['data'],
            external_type: member['data']['type'],
            account__holder: @bot.account__company
          )

          Core::Role.git_hub.create!(
            name: 'Member',
            resource: org,
            persona: persona
          )
        end

        outside_collaborators =
          GitHub::OutsideCollaboratorsClient
          .index @bot.sync__token.token, account['login']

        outside_collaborators.each do |member|
          persona = Core::Persona.create!(
            name: member['login'],
            external_id: member['id'],
            provider: 'GitHub',
            external_data: member['data'],
            external_type: member['data']['type'],
            account__holder: @bot.account__company
          )

          Core::Role.git_hub.create!(
            name: 'OutsideCollaborator',
            resource: org,
            persona: persona
          )
        end
      end
    end
  end
end
