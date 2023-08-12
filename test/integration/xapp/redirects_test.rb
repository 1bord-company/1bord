require "test_helper"

class Xapp::RedirectsTest < ActionDispatch::IntegrationTest
  def get_new_redirect(provider_id: 'GitHub', code: 'abcd',
                       installation_id: '123')

    get url_for [
      :new, :xapp, :provider, :redirect,
      { provider_id: provider_id, code: code, installation_id: installation_id }
    ]
  end

  test "visiting the index" do
    assert_difference [-> { Xapp::Redirect.count }, -> { Xapp::Bot.count }] do
      get_new_redirect
    end
    assert_no_difference([-> { Xapp::Redirect.count },
                          -> { Xapp::Bot.count }]) do
      get_new_redirect
    end
    assert_difference([-> { Xapp::Redirect.count }]) do
      get_new_redirect(code: 'wxyz')
    end
  end
end
