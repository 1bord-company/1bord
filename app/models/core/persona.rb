class Core::Persona < ApplicationRecord
  belongs_to :account__person,
             class_name: 'Account::Person'
end
