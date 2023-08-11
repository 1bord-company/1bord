class CreateSyncApiCalls < ActiveRecord::Migration[7.0]
  def change
    create_table 'sync/api_calls' do |t|
      t.belongs_to :token,
                   null: false,
                   foreign_key: { to_table: 'sync/tokens' }
      t.string :endpoint
      t.string :method
      t.jsonb :request_headers
      t.jsonb :request_body
      t.jsonb :response_headers
      t.jsonb :response_body
      t.integer :duration_ms

      t.timestamps
    end
  end
end
