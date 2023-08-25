class AsanaAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    workspaces_data = Asana::WorkspacesClient.index(@bot.token!.access_token)['data']
    workspaces_data.reject! { _1['name'] == 'Personal Projects' }

    workspaces = workspaces_data.map do |workspace_data|
      Ext::Resource
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          name: workspace_data['name'],
          external_id: workspace_data['gid'],
          provider: 'Asana',
          external_type: 'Workspace',
          external_data: workspace_data,
          account__company: @bot.account__company
    end

    memberships_data = workspaces.flat_map do |workspace|
      Asana::WorkspaceMembershipsClient
        .index(@bot.token!.access_token, workspace.external_id)['data']
    end

    memberships_data = memberships_data.map do |membership_data|
      Asana::WorkspaceMembershipsClient
        .show(@bot.token!.access_token, membership_data['gid'])['data']
    end

    memberships_data = memberships_data.map do |membership_data|
      membership_data['user'] = Asana::UsersClient
        .show(@bot.token!.access_token, membership_data['user']['gid'])['data']
      membership_data
    end
    users_data = memberships_data.group_by { _1['user'] }
    users_data.each { |user, memberships| users_data[user] = memberships.map { |membership| membership.except 'user' } }

    users_data.each do |user_data, memberships_data|
      persona = Ext::Persona
        .extending(ActiveRecord::CreateOrFindAndUpdateBy)
        .create_or_find_and_update_by! \
          external_id: user_data['gid'],
          external_type: 'User',
          external_data: user_data,
          provider: 'Asana',
          account__holder: @bot.account__company,
          name: user_data['name']

      memberships_data.each do |membership_data|
        Ext::Role.asana
          .extending(ActiveRecord::CreateOrFindAndUpdateBy)
          .create_or_find_and_update_by! \
            name: role(membership_data),
            persona: persona,
            resource: workspaces.find { _1.external_id == membership_data['workspace']['gid'] }
      end
    end

    workspaces.each do |workspace|
      Account::Audit.create! \
        auditor: @bot,
        auditee: workspace
    end
  end

  def role(membership_data)
    return 'Admin' if membership_data['is_admin']
    return 'Guest' if membership_data['is_guest']

    'Member'
  end
end
