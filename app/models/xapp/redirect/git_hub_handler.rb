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

        @bot = Xapp::Bot.find_or_create_by!(
          redirect: redirect,
          external_id: redirect.params['installation_id'],
          provider: 'GitHub'
        )

        @bot.sync__token!
        @bot.external_data!

        members =
          GitHub::MembersClient
          .index @bot.sync__token.token, @bot.external_data.dig('account', 'login')

        members.each do |member|
          Core::Persona.create!(
            name: member['login'],
            external_id: member['id'],
            provider: 'GitHub',
            external_data: member['data'],
            external_type: 'Member',
            account__holder: @bot.account__company
          )
        end

        outside_collaborators =
          GitHub::OutsideCollaboratorsClient
          .index @bot.sync__token.token, @bot.external_data.dig('account', 'login')

        outside_collaborators.each do |member|
          Core::Persona.create!(
            name: member['login'],
            external_id: member['id'],
            provider: 'GitHub',
            external_data: member['data'],
            external_type: 'OutsideCollaborator',
            account__holder: @bot.account__company
          )
        end
      end
    end
  end
end
