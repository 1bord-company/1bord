module Asana
  class WorkspacesClient < ResourceClient::Base
    BASE_URL = 'https://app.asana.com/api/1.0'.freeze

    def self.index(token) = new(token).index

    def index = get('workspaces')
  end
end
