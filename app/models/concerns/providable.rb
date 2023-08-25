module Providable
  extend ActiveSupport::Concern

  included do
    scope :git_hub, -> { where(provider: 'GitHub') }
    scope :slack, -> { where(provider: 'Slack') }
    scope :jira, -> { where(provider: 'Jira') }
    scope :heroku, -> { where(provider: 'Heroku') }
    scope :google, -> { where provider: 'Google' }
    scope :asana, -> { where provider: 'Asana' }
  end
end
