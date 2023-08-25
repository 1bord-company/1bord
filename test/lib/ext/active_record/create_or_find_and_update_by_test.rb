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
end
