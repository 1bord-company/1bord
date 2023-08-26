module Asana
  class WorkspaceMembershipsClient < ResourceClient
    def self.index(token, workspace_id) = new(token).index(workspace_id)
    def index(workspace_id)
      get "workspaces/#{workspace_id}/workspace_memberships"
    end

    def self.show(token, workspace_membership_id) = new(token).show(workspace_membership_id)
    def show(workspace_membership_id)
      get "workspace_memberships/#{workspace_membership_id}"
    end
  end
end
