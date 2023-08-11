class Account::User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  belongs_to :person, inverse_of: :user

  has_many :sync__tokens,
           class_name: 'Sync::Token',
           as: :authorizer
end
