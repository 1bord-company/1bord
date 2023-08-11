class Integration::Installation < ApplicationRecord
  belongs_to :account__company,
             class_name: 'Account::Company'

  has_many :sync__tokens,
           class_name: 'Sync::Token',
           as: :authorizer
end
