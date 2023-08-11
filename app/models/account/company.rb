class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company
  has_many :sync__tokens,
           class_name: 'Sync::Token'
end
