require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user
  end

  def self.test_provider(provider, check, diff, &block)
    data = YAML.load_file __FILE__.gsub(/\.rb$/, "/#{provider.underscore}.yml")

    test "#{provider}:#{check}" do
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
    base_records = YAML.load_file(__FILE__.gsub /\.rb$/, "/base.yml")['base']['records']
    base_records.merge(provider_records).map do |k,v|
      query = v['model']
      query << ".#{v['scopes'].join('.')}" if v['scopes']
      query << ".where(#{v['where'].map{ |attribute| attribute.map { |name, value| [name, value].join ': ' }}.join(', ') })" if v['where']
      query << ".where.not(#{v['where.not'].map{ |attribute| attribute.map { |name, value| [name, value].join ': ' }}.join(', ') })" if v['where.not']
      query << '.count'
      [query, v['count']]
    end.to_h
  end

  record_checks('GitHub').each do |check, diff|
    test_provider 'GitHub', check, diff do |creds|
      { code: creds.user.code, installation_id: creds.bot.id }
    end
  end

  record_checks('Slack').each do |check, diff|
    test_provider "Slack", check, diff
  end

  record_checks('Jira').each do |check, diff|
    test_provider "Jira", check, diff
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Bot')"\
      '.where.not(refresh_token: nil).count' => 1,
    "Ext::Resource.where(external_type: 'Team', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.where(external_type: 'User').count" => 3,
    "Ext::Role.where(name: 'admin').count" => 1,
    "Ext::Role.where(name: 'collaborator').count" => 1,
    "Ext::Role.where(name: 'member').count" => 1,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test_provider "Heroku", check, diff
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
