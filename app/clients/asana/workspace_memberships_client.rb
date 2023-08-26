require 'net/http'

module Asana
  class WorkspaceMembershipsClient < ResourceClient::Base
    BASE_URL = 'https://app.asana.com/api/1.0'.freeze

    def self.index(token, workspace_id) = new(token).index(workspace_id)
    def self.show(token, workspace_membership_id) = new(token).show(workspace_membership_id)

    def initialize(token) = @token = token

    def index(workspace_id)
      get "workspaces/#{workspace_id}/workspace_memberships"
    end

    def show(workspace_membership_id)
      get "workspace_memberships/#{workspace_membership_id}"
    end
  end
end
