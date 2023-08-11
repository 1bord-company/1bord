class Core::Resource < ApplicationRecord
  belongs_to :account__company,
             class_name: 'Account::Company'
end
