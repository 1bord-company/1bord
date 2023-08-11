class Sync::Webhook < ApplicationRecord
  belongs_to :integration__installation,
             class_name: 'Integration::Installation'
end
