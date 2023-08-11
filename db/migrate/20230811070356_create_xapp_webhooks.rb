class CreateXappWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table 'xapp/webhooks' do |t|
      t.string :endpoint
      t.jsonb :payload
      t.jsonb :headers
      t.belongs_to :bot,
                   null: false,
                   foreign_key: { to_table: 'xapp/bots' }

      t.timestamps
    end
  end
end
