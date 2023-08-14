module Account
  class Person < ApplicationRecord
    belongs_to :company, inverse_of: :people
    before_validation :create_company, on: :create

    has_one :user, inverse_of: :person

    has_many :core__entities,
             class_name: 'Core::Entity',
             as: :account__holder

    private

    def create_company
      self.company = Company.create! email: email
    end
  end
end
