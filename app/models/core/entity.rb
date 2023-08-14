class Core::Entity < ApplicationRecord
  belongs_to :account__holder,
             polymorphic: true
end
