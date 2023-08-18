module Account
  class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable,
           :confirmable, :lockable, :timeoutable, :trackable

    belongs_to :person, inverse_of: :user
    before_validation :create_profile, on: :create

    delegate :company, to: :person

    has_many :ext__tokens,
             as: :authorizer

    has_many :account__audits,
             as: :auditor

    private

    def create_profile
      self.person = Person.create! email: email
    end
  end
end
