module Asana
  class WorkspaceMembershipsClient < ResourceClient
    def self.index(token, workspace_id) = new(token).index(workspace_id)
    def index(workspace_id)
      get "workspaces/#{workspace_id}/workspace_memberships"
    end
  end
end
