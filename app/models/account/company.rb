class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company

  has_many :xapp__redirects,
           class_name: 'Xapp::Redirect',
           foreign_key: :account__company_id
  has_many :xapp__bots,
           through: :xapp__redirects,
           source: :bot,
           class_name: 'Xapp::Bot'
  has_many :sync__tokens, through: :xapp__bots
end
