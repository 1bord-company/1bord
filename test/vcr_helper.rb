require 'vcr'
require './lib/ext/vcr'

sensitive_data =
  %i[git_hub jira slack heroku google].flat_map do |provider|
  [
    [:providers, provider, :app, :id],
    [:providers, provider, :app, :client_id],
    [:providers, provider, :app, :client_secret],

    [:providers, provider, :bot, :id],
    [:providers, provider, :bot, :code],
    [:providers, provider, :bot, :token],
    [:providers, provider, :bot, :refresh_token],
  ]
end

VCR.configure do |config|
  config.ignore_hosts '127.0.0.1'

  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock

  sensitive_data.each do |credential_key|
    config.filter_sensitive_data("<CREDENTIAL:#{credential_key.join('.')}>") do
      Rails.application.credentials.dig(*credential_key)
    end
  end

  [
    %i[host_url]
  ].each do |url_key|
    config.filter_sensitive_data("<URL:#{url_key.join('.')}>") do
      CGI.escape(Rails.application.credentials.dig(*url_key))
    end
  end
end
