require "test_helper"

class Account::CompanyTest < ActiveSupport::TestCase
  test 'has_many :ext_tokens' do
    assert account_companies(:one).ext__tokens
  end
end
