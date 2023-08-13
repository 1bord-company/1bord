ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require 'vcr'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock

  [
    %i[providers git_hub app client_id],
    %i[providers git_hub app client_secret],
    %i[providers git_hub bot code],
    %i[providers git_hub bot token],
    %i[providers git_hub bot id],
    %i[providers slack app client_id],
    %i[providers slack app client_secret],
    %i[providers slack bot code],
    %i[providers slack bot token],
    %i[providers slack bot id]
  ].each do |credential_key|
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
