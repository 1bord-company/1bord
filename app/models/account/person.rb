class Account::Person < ApplicationRecord
  belongs_to :company, inverse_of: :people

  has_one :user, inverse_of: :person
end
