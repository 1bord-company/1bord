module GitHub
  class OutsideCollaboratorsClient < ResourceClient
    def self.index(token, org) = new(token).index(org)
    def index(org) = get("orgs/#{org}/outside_collaborators")
  end
end
