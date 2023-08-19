require 'test_helper'

class Account::JiraReauditsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user

    Ext::Bot.destroy_all

    VCR.insert_cassettes [
      'providers.jira.user_access_token_client#create',
      'providers.jira.accessible_resources_client#index',
      'providers.jira.users_client#index'
    ] do
      get url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'Jira', state: '',
          code: Rails.application.credentials.providers.jira.bot.code }
      ]
    end

    Ext::Resource.destroy_all
    Ext::Persona.destroy_all
    Ext::Role.destroy_all
  end

  {
    "Ext::Resource.where(external_type: 'Resource', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.where(external_type: 'User').count" => 1,
    "Ext::Persona.where(external_type: 'Bot').count" => 12,
    "Ext::Role.jira.where(name: 'Role').count" => 13,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "Jira:#{check}" do
      assert_difference check, diff do
        VCR.insert_cassettes [
          'providers.jira.accessible_resources_client#index',
          'providers.jira.users_client#index'
        ] do
          post url_for [:account, :audit]
        end
      end
    end
  end
end
