class Integration::Installation < ApplicationRecord
  belongs_to :account__company,
             class_name: 'Account::Company'
end
