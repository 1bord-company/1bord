class Sync::Token < ApplicationRecord
  belongs_to :account__company,
             class_name: 'Account::Company'

  belongs_to :authorizer,
             polymorphic: true
end
