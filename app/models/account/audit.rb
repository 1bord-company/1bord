class Account::Audit < ApplicationRecord
  belongs_to :auditor,
             polymorphic: true

  belongs_to :auditee,
             polymorphic: true
end
