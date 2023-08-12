require "application_system_test_case"

class Xapp::RedirectsTest < ApplicationSystemTestCase
  test "visiting the index" do
    assert_difference [-> { Xapp::Redirect.count }, -> { Xapp::Bot.count }] do
      visit url_for [
        :new, :xapp, :provider, :redirect,
        { provider_id: 'git_hub', code: 'abcd', installation_id: '1234' }
      ]
    end
  end
end
