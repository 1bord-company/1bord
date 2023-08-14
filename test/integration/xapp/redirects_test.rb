require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in account_users(:one)
    Xapp::Webhook.destroy_all
    Xapp::Bot.destroy_all
  end

  test 'GitHub' do
    user_creds = Rails.application.credentials.providers.git_hub.user
    bot_creds = Rails.application.credentials.providers.git_hub.bot

    assert_difference [
      -> { Xapp::Redirect.count },
      -> { Xapp::Bot.count },
      -> { Xapp::Bot.where.not(external_data: nil).count },
      -> { Sync::Token.where(authorizer_type: 'Account::User').count },
      -> { Sync::Token.where(authorizer_type: 'Xapp::Bot').count },
      -> { Core::Persona.where(provider: 'GitHub', external_type: 'Member', account__company: account_users(:one).company).count }
    ] do
      VCR.insert_cassette 'providers.git_hub.user_access_client#create'
      VCR.insert_cassette 'providers.git_hub.installation_access_token_client#create', erb: true
      VCR.insert_cassette 'providers.git_hub.installation_client.show'
      VCR.insert_cassette 'providers.git_hub.members_client.index'

      get url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'GitHub', code: user_creds.code,
          installation_id: bot_creds.id,
          setup_action: 'install' }
      ]

      VCR.eject_cassette
      VCR.eject_cassette
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
