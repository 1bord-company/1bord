class Xapp::Redirect < ApplicationRecord
  has_one :bot
  belongs_to :account__company,
             class_name: 'Account::Company'
end
