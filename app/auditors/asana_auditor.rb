class AsanaAuditor
  def self.audit!(bot) = new(bot).audit!

  def initialize(bot) = @bot = bot

  def audit!
    workspaces_data = Asana::WorkspacesClient.index(@bot.token!.access_token)['data']

    workspaces_data.each do |workspace_data|
      Ext::Resource.create_or_find_by! \
        name: workspace_data['name'],
        external_id: workspace_data['gid'],
        provider: 'Asana',
        external_type: 'Workspace',
        external_data: workspace_data,
        account__company: @bot.account__company
    end


  end
end
