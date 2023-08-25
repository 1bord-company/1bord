require 'test_helper'

class Account::SlackReauditsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user

    Ext::Bot.destroy_all

    VCR.insert_cassettes [
      'providers.slack.user_access_client#create',
      'providers.slack.users_client#index'
    ] do
      get url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'Slack', state: '',
          code: Rails.application.credentials.providers.slack.bot.code }
      ]

      Ext::Resource.destroy_all
      Ext::Persona.destroy_all
      Ext::Role.destroy_all
    end
  end

  {
    "Ext::Resource.slack.where(external_type: 'Workspace', "\
      'account__company: @account__user.company).count' => 1,
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
      assert_difference check, diff do
        VCR.insert_cassettes [
          'providers.slack.users_client#index'
        ] do
          post url_for [:account, :audit]
        end
      end
    end
  end
end
