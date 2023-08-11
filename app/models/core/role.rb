class Core::Role < ApplicationRecord
  belongs_to :resource
  belongs_to :persona
end
