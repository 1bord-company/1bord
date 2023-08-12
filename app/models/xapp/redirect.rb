class Xapp::Redirect < ApplicationRecord
  belongs_to :bot
  accepts_nested_attributes_for :bot
end
