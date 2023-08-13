class Account::Current < ActiveSupport::CurrentAttributes
  attribute :user, :person, :company

  def user=(user)
    super
    self.person = user&.person
    self.company = user&.company
  end
end
