module Jira
  class AccessibleResourcesClient < ResourceClient
    def self.index(token) = new(token).index
    def index = get('oauth/token/accessible-resources')
  end
end
