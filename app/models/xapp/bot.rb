class Xapp::Bot < ApplicationRecord
  belongs_to :redirect

  belongs_to :account__company,
             class_name: 'Account::Company',
             optional: true

  has_many :sync__tokens,
           class_name: 'Sync::Token',
           as: :authorizer
end
