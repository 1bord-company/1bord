class SlackAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    team_info = @bot.external_data!['team']
    @team = Ext::Resource
      .extending(ActiveRecord::CreateOrFindAndUpdateBy)
      .create_or_find_and_update_by! \
        name: team_info['name'],
        external_id: team_info['id'],
        provider: 'Slack',
        external_data: {},
        external_type: 'Workspace',
        account__company: @bot.account__company

    Account::Audit.create! auditor: @bot, auditee: @team

    Slack::UsersClient.index(@bot.token!.access_token).each do |member|
      persona = Ext::Persona
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          name: member['name'],
          external_id: member['id'],
          external_data: member['data'],
          external_type: member['data']['is_bot'] ? 'Bot' : 'User',
          account__holder: @bot.account__company,
          provider: 'Slack'

      Ext::Role.slack
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          name: role(member['data']), resource: @team, persona: persona
    end
  end

  private

  def role(member)
    return 'PrimaryOwner' if member['is_primary_owner']
    return 'Owner' if member['is_owner']
    return 'InvitedUser' if member['is_invited_user']
    return 'Guest' if member['is_restricted']
    return 'SingleChannelGuest' if member['is_ultra_restricted']
    return 'Stranger' if member['is_stranger']

    'Member'
  end
  end
