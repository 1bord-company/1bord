module Providable
  extend ActiveSupport::Concern

  included do
    scope :git_hub, -> { where(provider: 'GitHub') }
    scope :slack, -> { where(provider: 'Slack') }
    scope :jira, -> { where(provider: 'Jira') }
  end
end
