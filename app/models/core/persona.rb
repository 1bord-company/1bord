class Core::Persona < ApplicationRecord
  belongs_to :account__company,
             class_name: 'Account::Company'

  belongs_to :account__person,
             class_name: 'Account::Person',
             optional: true
end
