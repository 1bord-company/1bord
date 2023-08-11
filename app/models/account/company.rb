class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company
  has_many :users, through: :people
end
