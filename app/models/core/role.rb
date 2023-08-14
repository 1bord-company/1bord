class Core::Role < ApplicationRecord
  include Providable

  belongs_to :resource
  belongs_to :persona
end
