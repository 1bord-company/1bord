require "test_helper"

class Xapp::Providers::RedirectsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get xapp_providers_redirects_new_url
    assert_response :success
  end
end
