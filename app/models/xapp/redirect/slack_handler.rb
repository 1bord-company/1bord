module Xapp
  class Redirect < ApplicationRecord
    class SlackHandler
      def self.handle(redirect)
        token_info = Slack::UserAccessTokenClient.create(code: redirect.params['code'])

        @bot = Ext::Bot.find_or_create_by!(
          external_id: token_info['bot_user_id'],
          external_type: 'Bot',
          provider: 'Slack',
          external_data: token_info,
          account__company: Account::Current.company
        )

        @token = Ext::Token.create!(
          authorizer: @bot,
          provider: 'Slack',
          scope: token_info['scope'],
          token: token_info['access_token']
        )

        team_info = token_info['team']
        @team = Ext::Resource.create!(
          name: team_info['name'],
          external_id: team_info['id'],
          provider: 'Slack',
          external_data: {},
          external_type: 'Workspace',
          account__company: @bot.account__company
        )

        Slack::UsersClient.index(@token.token).each do |member|
          persona = Ext::Persona.create!(
            name: member['name'],
            external_id: member['id'],
            external_data: member['data'],
            external_type: member['data']['is_bot'] ? 'Bot' : 'User',
            account__holder: @bot.account__company,
            provider: 'Slack'
          )

          Ext::Role.slack.create!(
            name: role(member['data']), resource: @team, persona: persona
          )
        end
      end

      private

      def self.role(member)
        return 'PrimaryOwner' if member['is_primary_owner']
        return 'Owner' if member['is_owner']
        return 'InvitedUser' if member['is_invited_user']
        return 'Guest' if member['is_restricted']
        return 'SingleChannelGuest' if member['is_ultra_restricted']
        return 'Stranger' if member['is_stranger']

        'Member'
      end
    end
  end
end
