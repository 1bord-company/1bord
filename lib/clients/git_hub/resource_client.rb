module GitHub
  class ResourceClient < ::ResourceClient::Base
    private

    def headers = super.merge(
      'Accept' => 'application/vnd.github+json',
      'X-GitHub-Api-Version' => '2022-11-28'
    )
  end
end
