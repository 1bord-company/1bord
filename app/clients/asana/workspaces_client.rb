module Asana
  class WorkspacesClient < ResourceClient
    def self.index(token) = new(token).index
    def index = get('workspaces')
  end
end
