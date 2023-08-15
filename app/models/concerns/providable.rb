module Providable
  extend ActiveSupport::Concern

  included do
    scope :git_hub, -> { where(provider: 'GitHub') }
    scope :slack, -> { where(provider: 'Slack') }
  end
end
