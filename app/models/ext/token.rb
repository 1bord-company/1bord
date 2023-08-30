class Ext::Token < ApplicationRecord
  include Providable

  belongs_to :authorizer,
             polymorphic: true

  scope :valid, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }

  def authorizer=(new_authorizer)
    self.authorizer_id = new_authorizer.id
    self.authorizer_type = new_authorizer.class.name
    new_authorizer
  end
end
