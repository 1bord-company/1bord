module Jira
  class UsersClient < ResourceClient
    def self.index(token, resource_id) = new(token).index(resource_id)
    def index(resource_id) = get("ex/jira/#{resource_id}/rest/api/3/users")
  end
end
