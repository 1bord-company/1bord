require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user

    Xapp::Webhook.destroy_all
    Xapp::Bot.destroy_all
  end

  {
    'Xapp::Redirect.count' => 1,
    'Xapp::Bot.count' => 1,
    'Xapp::Bot.where.not(external_data: nil).count' => 1,
    "Sync::Token.where(authorizer_type: 'Account::User').count" => 1,
    "Sync::Token.where(authorizer_type: 'Xapp::Bot').count" => 1,
    "Core::Resource.git_hub.where(external_type: 'Organization', "\
      'account__holder: @account__user.company).count' => 1,
    "Core::Persona.git_hub.where(external_type: 'User', "\
      'account__holder: @account__user.company).count' => 4,
    "Core::Role.git_hub.where(name: 'Member').count" => 1,
    "Core::Role.git_hub.where(name: 'OutsideCollaborator').count" => 3
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
    'Xapp::Bot.count' => 1,
    'Xapp::Bot.where.not(external_data: nil).count' => 1,
    "Sync::Token.where(authorizer_type: 'Xapp::Bot').count" => 1,
    "Core::Resource.slack.where(external_type: 'Workspace', "\
      'account__holder: @account__user.company).count' => 1,
    "Core::Persona.slack.where(external_type: 'User', "\
      'account__holder: @account__user.company).count' => 3,
    "Core::Persona.slack.where(external_type: 'Bot', "\
      'account__holder: @account__user.company).count' => 1,
    "Core::Role.slack.where(name: 'Member').count" => 2,
    "Core::Role.slack.where(name: 'PrimaryOwner').count" => 1,
    "Core::Role.slack.where(name: 'InvitedUser').count" => 1
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
    'Sync::Token.where(authorizer: @account__user).count' => 1,
    "Core::Resource.where(external_type: 'Resource', "\
      'account__holder: @account__user.company).count' => 1,
    "Core::Persona.where(external_type: 'User').count" => 1,
    "Core::Persona.where(external_type: 'Bot').count" => 13,
    "Core::Role.jira.where(name: 'Role').count" => 14
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
