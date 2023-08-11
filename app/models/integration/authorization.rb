class Integration::Authorization < ApplicationRecord
  belongs_to :installation
  belongs_to :redirect
end
