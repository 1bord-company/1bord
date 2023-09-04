require "application_system_test_case"

class NavsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'all scenarios' do
    visit root_path
    within 'nav' do
      assert_no_text 'Logout'
    end

    @account__user = account_users(:one)
    sign_in @account__user

    visit root_path
    within 'nav' do
      assert_text @account__user.email
      assert_text @account__user.company.name
      assert_text 'Logout'
    end
  end
end
