class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company

  has_many :ext__resources,
           foreign_key: :account__holder_id

  has_many :ext__bots,
           foreign_key: :account__holder_id

  has_many :ext__personas,
           as: :account__holder

  has_many :xapp__redirects,
           foreign_key: :account__company_id

  has_many :ext__tokens,
           through: :ext__bots,
           source: :tokens
end
