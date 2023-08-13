class Xapp::Bot < ApplicationRecord
  belongs_to :redirect

  has_many :sync__tokens,
           class_name: 'Sync::Token',
           as: :authorizer
end
