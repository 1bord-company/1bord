module GitHub
  class OutsideCollaboratorsClient < ResourceClient::Base
    BASE_URL = 'https://api.github.com'.freeze

    def self.index(token, org) = new(token).index(org)

    def index(org) = get("orgs/#{org}/outside_collaborators")

    private

    def headers = super.merge(
      'Accept' => 'application/vnd.github+json',
      'X-GitHub-Api-Version' => '2022-11-28'
    )
  end
end
