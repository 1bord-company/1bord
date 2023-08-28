require 'test_helper'

class ActiveRecord::CreateOrFindAndUpdateByTest < ActiveSupport::TestCase
  test 'should update' do
    ext_persona = ext_personas(:one)
                  .tap { _1.update account__holder: Account::Person.first }

    attributes = {
      name: 'new name',
      account__holder: ext_persona.account__holder,
      external_id: ext_persona.external_id,
      external_type: ext_persona.external_type,
      external_data: { c: :c },
      provider: ext_persona.provider
    }

    assert_raise ActiveRecord::RecordNotFound do
      Ext::Persona.create_or_find_by! attributes
    end

    Ext::Persona
      .extending(ActiveRecord::CreateOrFindAndUpdateBy)
      .create_or_find_and_update_by! attributes
  end

  test 'polymorphic' do
    ext_resource = ext_resources(:repository_1)
                  .tap { _1.update account__company: Account::Company.first }

    attributes = {
      name: 'new name',
      account__company: ext_resource.account__company,
      external_id: ext_resource.external_id,
      external_type: ext_resource.external_type,
      external_data: { c: :c },
      provider: ext_resource.provider
    }

    assert_raise ActiveRecord::RecordNotFound do
      Ext::Resource.create_or_find_by! attributes
    end

    Ext::Resource
      .extending(ActiveRecord::CreateOrFindAndUpdateBy)
      .create_or_find_and_update_by! attributes
  end
end
