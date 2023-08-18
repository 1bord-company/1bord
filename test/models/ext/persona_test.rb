require "test_helper"

class Ext::PersonaTest < ActiveSupport::TestCase
  test 'account__holder_type' do
    resource = Ext::Persona.new account__holder: account_companies(:one)
    assert_equal 'Account::Company', resource.account__holder_type

    resource = Ext::Persona.new account__holder: account_people(:one)
    assert_equal 'Account::Person', resource.account__holder_type
  end
end
