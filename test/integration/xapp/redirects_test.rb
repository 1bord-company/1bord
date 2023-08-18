require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.count' => 1,
    'Ext::Bot.where.not(external_data: nil)'\
      '.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Account::User').count" => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Entity').count" => 1,
    "Ext::Resource.git_hub.where(external_type: 'Organization', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.git_hub.where(external_type: 'User', "\
      'account__holder: @account__user.company).count' => 4,
    "Ext::Role.git_hub.where(name: 'Member').count" => 1,
    "Ext::Role.git_hub.where(name: 'OutsideCollaborator').count" => 3,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "GitHub:#{check}" do
      assert_difference check, diff do
        VCR.insert_cassettes [
          'providers.git_hub.user_access_client#create',
          'providers.git_hub.installation_access_token_client#create',
          'providers.git_hub.installation_client.show',
          'providers.git_hub.members_client.index',
          'providers.git_hub.outside_collaborators_client.index'
        ] do
          git_hub_creds = Rails.application.credentials.providers.git_hub
          get url_for [
            :new, :xapp, :provider, :redirect,
            { provider_id: 'GitHub', code: git_hub_creds.user.code,
              installation_id: git_hub_creds.bot.id,
              setup_action: 'install' }
          ]

          assert_redirected_to root_path
        end
      end
    end
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.count' => 1,
    'Ext::Bot.where.not(external_data: nil)'\
      '.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Entity').count" => 1,
    "Ext::Resource.slack.where(external_type: 'Workspace', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.slack.where(external_type: 'User', "\
      'account__holder: @account__user.company).count' => 3,
    "Ext::Persona.slack.where(external_type: 'Bot', "\
      'account__holder: @account__user.company).count' => 1,
    "Ext::Role.slack.where(name: 'Member').count" => 2,
    "Ext::Role.slack.where(name: 'PrimaryOwner').count" => 1,
    "Ext::Role.slack.where(name: 'InvitedUser').count" => 1,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "Slack:#{check}" do
      assert_difference check, diff do
        VCR.insert_cassettes [
          'providers.slack.user_access_client#create',
          'providers.slack.users_client#index'
        ] do
          get url_for [
            :new, :xapp, :provider, :redirect,
            { provider_id: 'Slack', state: '',
              code: Rails.application.credentials.providers.slack.bot.code }
          ]

          assert_redirected_to root_path
        end
      end
    end
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.count' => 1,
    'Ext::Bot.where.not(external_data: nil)'\
      '.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Entity')"\
      '.where.not(refresh_token: nil).count' => 1,
    "Ext::Resource.where(external_type: 'Resource', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.where(external_type: 'User').count" => 1,
    "Ext::Persona.where(external_type: 'Bot').count" => 13,
    "Ext::Role.jira.where(name: 'Role').count" => 14,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "Jira:#{check}" do
      assert_difference check, diff do
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

          assert_redirected_to root_path
        end
      end
    end
  end
end
