class Sync::Token < ApplicationRecord
  belongs_to :authorizer,
             polymorphic: true
end
