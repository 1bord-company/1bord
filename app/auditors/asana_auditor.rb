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

    workspaces.each do |workspace|
      users_data = Asana::UsersClient
        .index(@bot.token!.access_token, workspace.external_id)['data']

      users_data.each do |user_data|
        # user_data.merge! Asana::UsersClient.show(@bot.token!.access_token, user_data['gid'])['data']

        Ext::Persona.create_or_find_by!(
          external_id: user_data['gid'],
          provider: 'Asana',
          external_type: 'User',
          account__holder: @bot.account__company
        ).tap do |persona|
          persona.update!(
            name: persona.name || user_data['name'],
            external_data: persona.external_data.merge(user_data),
          )
        end
      end
    end

  end
end
