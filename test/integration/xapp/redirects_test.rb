require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user
  end

  def self.test_provider(provider, check, diff, &block)
    data = YAML.load_file __FILE__.gsub(/\.rb$/, "/#{provider.underscore}.yml")

    test "#{provider}:#{check}==#{diff}" do
      [diff, check == 'Account::Audit.count' ? diff : 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes provider.underscore,
            data[provider.underscore]['cassettes'] do
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
      vs.map! { base_templates[k].merge _1 }

      vs.map do |v|
        query = "#{v['model']}"
        query << ".where(#{v['where'].map{ |name, value| [name, value].join ': ' }.join(', ')})" if v['where']
        query << ".where.not(#{v['where.not'].map{ |name, value| [name, value].join ': ' }.join(', ')})" if v['where.not']
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

  %w[Slack Jira Heroku].each do |provider|
    record_checks(provider).each do |check, diff|
      test_provider provider, check, diff
    end
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Bot')"\
      '.where.not(refresh_token: nil).count' => 1,
    "Ext::Resource.where(external_type: 'Domain', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.where(external_type: 'User').count" => 2,
    "Ext::Role.where(name: 'admin').count" => 1,
    "Ext::Role.where(name: 'member').count" => 1,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test_provider "Google", check, diff
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Bot')"\
      '.where.not(refresh_token: nil).count' => 1,
    "Ext::Resource.where(external_type: 'Workspace', "\
      'account__company: @account__user.company).count' => 2,
    "Ext::Persona.where(external_type: 'User').count" => 6,
    "Ext::Persona.where(\"external_data ->> 'email' IS NOT NULL\").count" => 6,
    "Ext::Role.where(name: 'Admin').count" => 0,
    "Ext::Role.where(name: 'Guest').count" => 5,
    "Ext::Role.where(name: 'Member').count" => 2,
    'Account::Audit.count' => 2
  }.each do |check, diff|
    test_provider "Asana", check, diff
  end
end
