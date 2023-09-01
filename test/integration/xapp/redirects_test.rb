require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user
  end

  def self.test_provider(provider, check, diff, &block)
    base_cassettes = YAML.load_file(__FILE__.gsub /\.rb$/, '/base.yml')['base']['cassettes']
    provider_cassettes = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider.underscore}.yml")[provider.underscore]['cassettes']

    test "#{provider}:#{check}==#{diff}" do
      [diff, 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes provider.underscore,
            (base_cassettes + provider_cassettes) do
            get_redirect provider, &block

            assert_redirected_to root_path
          end
        end
      end
    end
  end

  def get_redirect(provider)
    creds = Rails.application.credentials.providers[provider.underscore]
    params = { provider_id: provider, code: creds.bot.code }
    params.merge! yield(creds) if block_given?

    get url_for [:new, :xapp, :provider, :redirect, params]
  end

  def self.record_checks(provider)
    provider_records = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider.underscore}.yml")[provider.underscore]['records']
    base = YAML.load_file(__FILE__.gsub /\.rb$/, "/base.yml")['base']
    base_records = base['records']
    base_templates = base['templates']

    base_records.merge(provider_records).flat_map do |k,vs|
      base_template = base_templates[k]

      vs.map do |v|
        query = "#{base_template['model']}"
        query << ".where(#{(base_template['where'] || {}).merge(v['where'] || {}).map{ |name, value| [name, value].join ': ' }.join(', ')})" if v['where'] || base_template['where']
        query << ".where.not(#{(base_template['where.not'] || {}).merge(v['where.not'] || {}).map{ |name, value| [name, value].join ': ' }.join(', ')})" if v['where.not'] || base_template['where.not']
        query << '.count'
        [query, v['count']]
      end
    end.to_h
  end

  record_checks('GitHub').each do |check, diff|
    test_provider 'GitHub', check, diff do |creds|
      { code: creds.user.code, installation_id: creds.bot.id }
    end
  end

  %w[Slack Jira Heroku Google Asana].each do |provider|
    record_checks(provider).each do |check, diff|
      test_provider provider, check, diff
    end
  end
end
