class Ext::Token < ApplicationRecord
  belongs_to :authorizer,
             polymorphic: true

  scope :valid, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }

  def expires_in=(seconds)
    self.expires_at ||= Time.current + seconds.to_i.seconds
  end
end
