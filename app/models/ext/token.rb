class Ext::Token < ApplicationRecord
  belongs_to :authorizer,
             polymorphic: true

  scope :valid, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }
end
