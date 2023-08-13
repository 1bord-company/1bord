require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in account_users(:one)
  end

  test 'GitHub' do
    user_creds = Rails.application.credentials.providers.git_hub.user
    bot_creds = Rails.application.credentials.providers.git_hub.bot

    assert_difference [
      -> { Xapp::Redirect.count },
      -> { Xapp::Bot.count },
      -> { Sync::Token.where(authorizer_type: 'Account::User').count },
      -> { Sync::Token.where(authorizer_type: 'Xapp::Bot').count }
    ] do
      VCR.insert_cassette('providers.git_hub.user_access_client#create')
      VCR.insert_cassette('providers.git_hub.installation_access_token_client#create')

      get url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'GitHub', code: user_creds.code,
          installation_id: bot_creds.id,
          setup_action: 'install' }
      ]

      VCR.eject_cassette
      VCR.eject_cassette
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
