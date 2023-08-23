require 'vcr'
require './lib/ext/vcr'

sensitive_data = [
  %i[providers git_hub app client_id],
  %i[providers git_hub app client_secret],
  %i[providers git_hub bot code],
  %i[providers git_hub bot token],
  %i[providers git_hub bot id],

  %i[providers jira app id],
  %i[providers jira app client_id],
  %i[providers jira app client_secret],
  %i[providers jira bot code],
  %i[providers jira bot token],
  %i[providers jira bot refresh_token],

  %i[providers slack app client_id],
  %i[providers slack app client_secret],
  %i[providers slack bot code],
  %i[providers slack bot token],
  %i[providers slack bot id],

  %i[providers heroku app client_id],
  %i[providers heroku app client_secret],
  %i[providers heroku bot code],
  %i[providers heroku bot token],
  %i[providers heroku bot id],
  %i[providers heroku bot refresh_token],

  %i[providers google app client_id],
  %i[providers google app client_secret],
  %i[providers google bot code],
  %i[providers google bot token],
  %i[providers google bot id],
  %i[providers google bot refresh_token]
]

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
