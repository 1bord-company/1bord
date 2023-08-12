require 'test_helper'

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  test 'storing the redirect' do
    bot_creds = Rails.application.credentials.providers.git_hub.bot

    assert_difference [
      -> { Xapp::Redirect.count },
      -> { Xapp::Bot.count },
      -> { Sync::Token.count }
    ] do
      VCR.insert_cassette('providers.git_hub.user_access_client#create')

      get url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'GitHub', code: bot_creds.code,
          installation_id: bot_creds.id,
          setup_action: 'install' }
      ]

      VCR.eject_cassette
    end
  end
end
