class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company

  has_many :core__resources,
           foreign_key: :account__holder_id

  has_many :core__bots,
           foreign_key: :account__holder_id

  has_many :core__personas,
           as: :account__holder

  has_many :xapp__redirects,
           foreign_key: :account__company_id

  has_many :sync__tokens, through: :core__bots
end
