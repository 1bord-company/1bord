class Account::Current < ActiveSupport::CurrentAttributes
  def self.company = Account::Company.first
end
