class AsanaAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    workspaces_data = Asana::WorkspacesClient.index(@bot.token!.access_token)['data']
    workspaces_data.reject! { _1['name'] == 'Personal Projects' }

    workspaces = workspaces_data.map do |workspace_data|
      Ext::Resource.create_or_find_by! \
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

    debugger
      # Ext::Persona.create_or_find_by!(
        # external_id: user_data['gid'],
        # provider: 'Asana',
        # external_type: 'User',
        # account__holder: @bot.account__company
      # ).tap do |persona|
        # persona.update!(
          # name: persona.name || user_data['name'],
          # external_data: persona.external_data.merge(user_data),
        # )
      # end
  end
end
