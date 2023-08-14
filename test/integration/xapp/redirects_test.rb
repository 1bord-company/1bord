require 'test_helper'
require './lib/ext/vcr'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in account_users(:one)
    Xapp::Webhook.destroy_all
    Xapp::Bot.destroy_all
  end

  git_hub_cassettes = [
    'providers.git_hub.user_access_client#create',
    'providers.git_hub.installation_access_token_client#create',
    'providers.git_hub.installation_client.show',
    'providers.git_hub.members_client.index',
    'providers.git_hub.outside_collaborators_client.index'
  ]

  test 'GitHub' do
    git_hub_creds = Rails.application.credentials.providers.git_hub

    assert_difference [
      -> { Xapp::Redirect.count },
      -> { Xapp::Bot.count },
      -> { Xapp::Bot.where.not(external_data: nil).count },
      -> { Sync::Token.where(authorizer_type: 'Account::User').count },
      -> { Sync::Token.where(authorizer_type: 'Xapp::Bot').count },
      lambda {
        Core::Persona
          .where(provider: 'GitHub', external_type: 'Member',
                 account__holder: account_users(:one).company)
          .count
      }
    ] do
      VCR.insert_cassettes git_hub_cassettes do
        get url_for [
          :new, :xapp, :provider, :redirect,
          { provider_id: 'GitHub', code: git_hub_creds.user.code,
            installation_id: git_hub_creds.bot.id,
            setup_action: 'install' }
        ]
      end
    end
  end

  test 'Slack' do
    bot_creds = Rails.application.credentials.providers.slack.bot

    assert_difference [
      -> { Xapp::Redirect.count },
      -> { Xapp::Bot.where(provider: 'Slack').count },
      -> { Sync::Token.where(provider: 'Slack').count }
    ] do
      VCR.insert_cassette('providers.slack.user_access_client#create')

      get url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'Slack', code: bot_creds.code }
      ]

      VCR.eject_cassette
    end
  end
end
