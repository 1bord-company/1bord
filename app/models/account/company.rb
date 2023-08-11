class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company
end
