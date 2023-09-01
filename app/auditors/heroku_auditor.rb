class HerokuAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    teams = Heroku::TeamsClient
      .index(@bot.token!.access_token)
      .map do |team_data|
        Ext::Resource
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            name: team_data['name'],
            external_id: team_data['id'],
            external_data: team_data,
            external_type: 'Team',
            provider: 'Heroku',
            account__company: @bot.account__company
      end

    teams.each do |team|
      Heroku::MembersClient
        .index(@bot.token!.access_token, team.external_id)
        .each do |member_data|
          persona = Ext::Persona
            .extending(ActiveRecord::CreateOrFindAndUpdateBy)
            .create_or_find_and_update_by! \
              name: member_data['user']['name'],
              external_id: member_data['user']['id'],
              external_type: 'User',
              external_data: member_data,
              provider: 'Heroku',
              account__holder: @bot.account__company

          Ext::Role
            .extending(ActiveRecord::CreateOrFindAndUpdateBy)
            .create_or_find_and_update_by! \
              persona: persona,
              resource: team,
              provider: 'Heroku',
              name: member_data['role']
        end

      Heroku::InvitationsClient
        .index(@bot.token!.access_token, team.external_id)
        .each do |invitation_data|
          persona = Ext::Persona
            .extending(ActiveRecord::CreateOrFindAndUpdateBy)
            .create_or_find_and_update_by! \
              name: invitation_data['user']['name'],
              external_id: invitation_data['user']['id'],
              external_type: 'User',
              external_data: invitation_data,
              provider: 'Heroku',
              account__holder: @bot.account__company

          Ext::Role
            .extending(ActiveRecord::CreateOrFindAndUpdateBy)
            .create_or_find_and_update_by! \
              persona: persona,
              resource: team,
              provider: 'Heroku',
              name: invitation_data['role']
        end
    end
  end
end
