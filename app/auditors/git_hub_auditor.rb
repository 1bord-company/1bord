class GitHubAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    account = @bot.external_data!['account']

    org = Ext::Resource.create_or_find_by!(
      name: account['login'],
      external_id: account['id'],
      provider: 'GitHub',
      external_data: account,
      external_type: account['type'],
      account__company: @bot.account__company
    )

    Account::Audit.create! auditor: @bot, auditee: org

    members =
      GitHub::MembersClient
      .index @bot.token!.token, account['login']

    members.each do |member|
      persona = Ext::Persona.create_or_find_by!(
        name: member['login'],
        external_id: member['id'],
        provider: 'GitHub',
        external_data: member['data'],
        external_type: member['data']['type'],
        account__holder: @bot.account__company
      )

      Ext::Role.git_hub.create_or_find_by!(
        name: 'Member',
        resource: org,
        persona: persona
      )
    end

    outside_collaborators =
      GitHub::OutsideCollaboratorsClient
      .index @bot.token!.token, account['login']

    outside_collaborators.each do |member|
      persona = Ext::Persona.create_or_find_by!(
        name: member['login'],
        external_id: member['id'],
        provider: 'GitHub',
        external_data: member['data'],
        external_type: member['data']['type'],
        account__holder: @bot.account__company
      )

      Ext::Role.git_hub.create_or_find_by!(
        name: 'OutsideCollaborator',
        resource: org,
        persona: persona
      )
    end
  end
end
