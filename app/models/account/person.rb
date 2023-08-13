module Account
  class Person < ApplicationRecord
    belongs_to :company, inverse_of: :people
    before_validation :create_company, on: :create

    has_one :user, inverse_of: :person

    private

    def create_company
      self.company = Company.create! email: email
    end
  end
end
