module GitHub
  class ResourceClient < ResourceClient::Base
    BASE_URL = 'https://api.github.com'.freeze

    private

    def headers = super.merge(
      'Accept' => 'application/vnd.github+json',
      'X-GitHub-Api-Version' => '2022-11-28'
    )
  end
end
