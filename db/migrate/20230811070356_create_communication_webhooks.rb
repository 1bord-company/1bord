class CreateCommunicationWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table 'communication/webhooks' do |t|
      t.string :endpoint
      t.jsonb :payload
      t.jsonb :headers
      t.belongs_to :integration__installation,
        null: false,
        foreign_key: { to_table: 'integration/installations' }

      t.timestamps
    end
  end
end
