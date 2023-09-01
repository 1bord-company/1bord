class GitHubAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    account = @bot.external_data!['account']

    org = Ext::Resource
      .extending(ActiveRecord::CreateOrFindAndUpdateBy)
      .create_or_find_and_update_by! \
        name: account['login'],
        external_id: account['id'],
        provider: 'GitHub',
        external_data: account,
        external_type: account['type'],
        account__company: @bot.account__company

    members =
      GitHub::MembersClient
      .index @bot.token!.access_token, account['login']

    members.each do |member|
      persona = Ext::Persona
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          name: member['login'],
          external_id: member['id'],
          provider: 'GitHub',
          external_data: member,
          external_type: member['type'],
          account__holder: @bot.account__company

      Ext::Role.git_hub
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          name: 'Member',
          resource: org,
          persona: persona
    end

    outside_collaborators =
      GitHub::OutsideCollaboratorsClient
      .index @bot.token!.access_token, account['login']

    outside_collaborators.each do |member|
      persona = Ext::Persona
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          name: member['login'],
          external_id: member['id'],
          provider: 'GitHub',
          external_data: member,
          external_type: member['type'],
          account__holder: @bot.account__company

      Ext::Role.git_hub
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          name: 'OutsideCollaborator',
          resource: org,
          persona: persona
    end
  end
end
