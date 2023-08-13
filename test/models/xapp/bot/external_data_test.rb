require 'test_helper'

class Xapp::BotTest < ActiveSupport::TestCase
  test 'normal call return nil when not present' do
    bot = xapp_bots(:one)

    assert_nil bot.external_data
  end

  test 'power call return data' do
    bot = xapp_bots(:one)

    VCR.insert_cassette 'providers.git_hub.installation_client.show'
    assert_not_nil bot.external_data!
    assert_not_nil bot.external_data

    VCR.eject_cassette
  end
end
