require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    Ext::Bot.destroy_all

    @account__user = account_users(:one)
    sign_in @account__user
  end

  def get_redirect(provider)
    creds = Rails.application.credentials.providers[provider.underscore]
    params = { provider_id: provider, code: creds.bot.code }
    params.merge! yield(creds) if block_given?

    get url_for [:new, :xapp, :provider, :redirect, params]
  end

  def install(provider, &block)
    base_cassettes = YAML.load_file(__FILE__.gsub /\.rb$/, '/base.yml')['base']['cassettes']
    provider_cassettes = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider.underscore}.yml")[provider.underscore]['cassettes']

    VCR.insert_provider_cassettes provider.underscore,
      (base_cassettes + provider_cassettes) do
        get_redirect provider, &block
      end
  end

  def reaudit(provider)
    base_cassettes = YAML.load_file(__FILE__.gsub /\.rb$/, '/base.yml')['base']['cassettes']
    provider_cassettes = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider.underscore}.yml")[provider.underscore]['cassettes']

    VCR.insert_provider_cassettes provider.underscore,
      provider_cassettes do
        post url_for %i[account audit]
      end
  end

  def reset_ext
    Ext::Resource.destroy_all
    Ext::Persona.destroy_all
    Ext::Role.destroy_all
  end

  def self.test_provider(provider, &block)
    record_checks(provider).each do |check, diff|
      test "Installation:#{provider}:#{check}==#{diff}##{SecureRandom.hex(6)}" do
        assert_difference(check, diff) { install provider, &block }
      end

      test "TestReaudit:#{provider}:#{check}==#{0}##{SecureRandom.hex(6)}" do
        install provider, &block

        assert_difference(check, 0) { reaudit provider }
      end
    end

    entity_checks(provider).each do |check, diff|
      test "RealReaudit:#{provider}:#{check}==#{0}##{SecureRandom.hex(6)}" do
        install provider, &block
        reset_ext

        assert_difference(check, diff) { reaudit provider }
      end
    end
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

  def self.entity_checks(provider)
    provider_records = YAML.load_file(__FILE__.gsub /\.rb$/, "/#{provider.underscore}.yml")[provider.underscore]['records']
    base = YAML.load_file(__FILE__.gsub /\.rb$/, "/base.yml")['base']
    base_templates = base['templates']

    provider_records.flat_map do |k,vs|
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

  test_provider 'GitHub' do |creds|
    { code: creds.user.code, installation_id: creds.bot.id }
  end

  %w[Slack Jira Heroku Google Asana].each do |provider|
    test_provider provider
  end
end
