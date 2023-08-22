require 'test_helper'

class Account::HerokuReauditsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user

    Ext::Bot.destroy_all

    VCR.insert_cassettes [
      'providers.heroku.bot_access_token_client#create',
      'providers.heroku.teams_client#index',
      'providers.heroku.members_client#index',
      'providers.heroku.invitations_client#index'
    ] do
      get url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'Heroku', state: '',
          code: Rails.application.credentials.providers.heroku.bot.code }
      ]
    end

    Ext::Resource.destroy_all
    Ext::Persona.destroy_all
    Ext::Role.destroy_all
  end

  {
    "Ext::Resource.where(external_type: 'Team', "\
      'account__company: @account__user.company).count' => 1,
    "Ext::Persona.where(external_type: 'User').count" => 3,
    "Ext::Role.heroku.where(name: 'admin').count" => 1,
    "Ext::Role.heroku.where(name: 'collaborator').count" => 1,
    "Ext::Role.heroku.where(name: 'member').count" => 1,
    'Account::Audit.count' => 1
  }.each do |check, diff|
    test "Heroku:#{check}" do
      Ext::Bot.heroku.last.token.update expires_at: 1.second.ago

      assert_difference check, diff do
        VCR.insert_cassettes [
          'providers.heroku.bot_access_token_client#create',
          'providers.heroku.teams_client#index',
          'providers.heroku.members_client#index',
          'providers.heroku.invitations_client#index'
        ] do
          post url_for [:account, :audit]
        end
      end
    end
  end
end
