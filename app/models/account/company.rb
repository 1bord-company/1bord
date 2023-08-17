class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company

  has_many :core__resources,
           class_name: 'Core::Resource',
           foreign_key: :account__holder_id

  has_many :core__bots,
           class_name: 'Core::Bot',
           foreign_key: :account__holder_id

  has_many :core__personas,
           class_name: 'Core::Persona',
           as: :account__holder

  has_many :xapp__redirects,
           class_name: 'Xapp::Redirect',
           foreign_key: :account__company_id

  has_many :sync__tokens, through: :core__bots
end
