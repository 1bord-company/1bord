require 'test_helper'

class Account::GitHubReauditsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user

    Ext::Bot.destroy_all

    VCR.insert_cassettes [
      'providers.git_hub.bot_access_token_client#create',
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
    end
  end

  def delete_ext_records
    Ext::Resource.destroy_all
    Ext::Persona.destroy_all
    Ext::Role.destroy_all
  end

  {
    "Ext::Resource.git_hub.where(external_type: 'Organization', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.git_hub.where(external_type: 'User', "\
      'account__holder: @account__user.company).count' => 4,
    "Ext::Role.git_hub.where(name: 'Member').count" => 1,
    "Ext::Role.git_hub.where(name: 'OutsideCollaborator').count" => 3,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "GitHub:#{check}" do
      assert_difference check, check == 'Account::Audit.count' ? 1 : 0 do
        VCR.insert_cassettes [
          'providers.git_hub.installation_client.show',
          'providers.git_hub.members_client.index',
          'providers.git_hub.outside_collaborators_client.index'
        ] do
          post url_for %i[account audit]
        end
      end

      delete_ext_records

      assert_difference check, diff do
        VCR.insert_cassettes [
          'providers.git_hub.installation_client.show',
          'providers.git_hub.members_client.index',
          'providers.git_hub.outside_collaborators_client.index'
        ] do
          post url_for %i[account audit]
        end
      end
    end
  end
end
