class Sync::Token < ApplicationRecord
  belongs_to :authorizer,
             polymorphic: true

  scope :valid, -> { where 'expires_at > ?', Time.current }
end
