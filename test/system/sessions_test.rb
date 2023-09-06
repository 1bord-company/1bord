require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'all scenarios' do
    @account__user = account_users(:one)

    visit root_path

    within 'form#new_account_user' do
      fill_in 'Email', with: @account__user.email
      fill_in 'Password', with: 'password'
      click_button 'Log in'
    end

    within 'nav' do
      assert_text @account__user.name
      assert_text @account__user.company.name

      find('details > summary').click
      click_button 'Log out'
    end

    assert_text 'Log in'
  end
end
