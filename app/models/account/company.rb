class Account::Company < ApplicationRecord
  has_many :people, inverse_of: :company

  has_many :core__entities,
           class_name: 'Core::Entity',
           as: :account__holder

  has_many :core__resources,
           class_name: 'Core::Resource',
           as: :account__holder

  has_many :xapp__redirects,
           class_name: 'Xapp::Redirect',
           foreign_key: :account__company_id

  has_many :core__bots,
           class_name: 'Core::Bot',
           as: :account__holder

  has_many :sync__tokens, through: :core__bots
end
