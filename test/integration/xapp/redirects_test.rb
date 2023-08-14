require 'test_helper'
require './lib/ext/vcr'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @account__user = account_users(:one)
    sign_in @account__user

    Xapp::Webhook.destroy_all
    Xapp::Bot.destroy_all
  end

  git_hub_differences = lambda { |account__user|
    [
      -> { Xapp::Redirect.count },
      -> { Xapp::Bot.count },
      -> { Xapp::Bot.where.not(external_data: nil).count },
      -> { Sync::Token.where(authorizer_type: 'Account::User').count },
      -> { Sync::Token.where(authorizer_type: 'Xapp::Bot').count },
      lambda {
        Core::Persona
          .where(provider: 'GitHub', external_type: 'Member',
                 account__holder: account__user.company)
          .count
      }
    ]
  }

  git_hub_cassettes = [
    'providers.git_hub.user_access_client#create',
    'providers.git_hub.installation_access_token_client#create',
    'providers.git_hub.installation_client.show',
    'providers.git_hub.members_client.index',
    'providers.git_hub.outside_collaborators_client.index'
  ]

  git_hub_creds = Rails.application.credentials.providers.git_hub

  git_hub_url = [
    :new, :xapp, :provider, :redirect,
    { provider_id: 'GitHub', code: git_hub_creds.user.code,
      installation_id: git_hub_creds.bot.id,
      setup_action: 'install' }
  ]

  test 'GitHub' do
    assert_difference git_hub_differences[@account__user] do
      VCR.insert_cassettes git_hub_cassettes do
        get url_for git_hub_url
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
