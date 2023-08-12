class CreateSyncTokens < ActiveRecord::Migration[7.0]
  def change
    create_table 'sync/tokens' do |t|
      t.string :token
      t.string :type
      t.string :provider
      t.string :scope
      t.string :authorizer_type
      t.bigint :authorizer_id
      t.timestamp :expires_at

      t.timestamps
    end
  end
end
