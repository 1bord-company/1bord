class CreateSyncWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table 'sync/webhooks' do |t|
      t.string :endpoint
      t.jsonb :payload
      t.jsonb :headers
      t.belongs_to :xapp__installation,
                   null: false,
                   foreign_key: { to_table: 'xapp/installations' }

      t.timestamps
    end
  end
end
