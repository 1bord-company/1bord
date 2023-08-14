class Core::Entity < ApplicationRecord
  include Providable

  belongs_to :account__holder,
             polymorphic: true
end
