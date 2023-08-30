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
    "Ext::Token.where(authorizer_type: 'Ext::Bot').count" => 1,
    "Ext::Resource.git_hub.where(external_type: 'Organization', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.git_hub.where(external_type: 'User', "\
      'account__holder: @account__user.company).count' => 4,
    "Ext::Role.git_hub.where(name: 'Member').count" => 1,
    "Ext::Role.git_hub.where(name: 'OutsideCollaborator').count" => 3,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "GitHub:#{check}" do
      [diff, check == 'Account::Audit.count' ? diff : 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes 'git_hub', [
            'user_access_client#create',
            'installation_access_token_client#create',
            'installation_client.show',
            'members_client.index',
            'outside_collaborators_client.index'
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
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.count' => 1,
    'Ext::Bot.where.not(external_data: nil)'\
      '.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Bot').count" => 1,
    "Ext::Resource.slack.where(external_type: 'Workspace', "\
      'account__company: @account__user.company)'\
      '.where.not(external_data: {}).count' => 1,
    "Ext::Persona.slack.where(external_type: 'User', "\
      'account__holder: @account__user.company).count' => 3,
    "Ext::Persona.slack.where(external_type: 'Bot', "\
      'account__holder: @account__user.company).count' => 0,
    "Ext::Role.slack.where(name: 'Member').count" => 1,
    "Ext::Role.slack.where(name: 'PrimaryOwner').count" => 1,
    "Ext::Role.slack.where(name: 'InvitedUser').count" => 1,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "Slack:#{check}" do
      [diff, check == 'Account::Audit.count' ? diff : 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes 'slack', [
            'user_access_client#create',
            'teams_client#show',
            'users_client#index'
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
  end

  {
    'Xapp::Redirect.count' => 1,
    'Ext::Bot.count' => 1,
    'Ext::Bot.where.not(external_data: nil)'\
      '.where(account__company: @account__user.company).count' => 1,
    "Ext::Token.where(authorizer_type: 'Ext::Bot')"\
      '.where.not(refresh_token: nil).count' => 1,
    "Ext::Resource.where(external_type: 'Resource', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.where(external_type: 'User').count" => 1,
    "Ext::Persona.where(external_type: 'Bot').count" => 12,
    "Ext::Role.jira.where(name: 'Role').count" => 13,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "Jira:#{check}" do
      [diff, check == 'Account::Audit.count' ? diff : 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes 'jira', [
            'bot_access_token_client#create',
            'accessible_resources_client#index',
            'users_client#index'
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
    test "Heroku:#{check}" do
      [diff, check == 'Account::Audit.count' ? diff : 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes 'heroku', [
            'bot_access_token_client#create',
            'teams_client#index',
            'members_client#index',
            'invitations_client#index'
          ] do
            get url_for [
              :new, :xapp, :provider, :redirect,
              { provider_id: 'Heroku', state: '',
                code: Rails.application.credentials.providers.heroku.bot.code }
            ]

            assert_redirected_to root_path
          end
        end
      end
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
    test "Google:#{check}" do
      [diff, check == 'Account::Audit.count' ? diff : 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes 'google', [
            'bot_access_token_client#create',
            'users_client#index',
          ] do
            get url_for [
              :new, :xapp, :provider, :redirect,
              { provider_id: 'Google', state: '',
                code: Rails.application.credentials.providers.google.bot.code }
            ]

            assert_redirected_to root_path
          end
        end
      end
    end
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
    test "Asana:#{check}" do
      [diff, check == 'Account::Audit.count' ? diff : 0].each do |diff|
        assert_difference check, diff do
          VCR.insert_provider_cassettes 'asana', [
            'bot_access_token_client#create',
            'workspaces_client#index',
            'workspace_memberships_client#index',
            'workspace_memberships_client#show',
            'users_client#show',
          ] do
            get url_for [
              :new, :xapp, :provider, :redirect,
              { provider_id: 'Asana', state: '',
                code: Rails.application.credentials.providers.asana.bot.code }
            ]

            assert_redirected_to root_path
          end
        end
      end
    end
  end
end
