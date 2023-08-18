require "test_helper"

class Ext::ResourceTest < ActiveSupport::TestCase
  test 'account__holder_type' do
    resource = Ext::Resource.new account__company: account_companies(:one)
    assert_equal 'Account::Company', resource.account__holder_type
  end
end
