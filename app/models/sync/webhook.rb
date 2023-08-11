class Sync::Webhook < ApplicationRecord
  belongs_to :xapp__installation,
             class_name: 'Xapp::Installation'
end
