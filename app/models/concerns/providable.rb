module Providable
  extend ActiveSupport::Concern

  included do
    scope :git_hub, -> { where(provider: 'GitHub') }
  end
end
