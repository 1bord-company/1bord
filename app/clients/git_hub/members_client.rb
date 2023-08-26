module GitHub
  class MembersClient < ResourceClient
    def self.index(token, org) = new(token).index(org)
    def index(org) = get("orgs/#{org}/members")
  end
end
