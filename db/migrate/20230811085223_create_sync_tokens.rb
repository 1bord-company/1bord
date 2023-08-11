class CreateSyncTokens < ActiveRecord::Migration[7.0]
  def change
    create_table 'sync/tokens' do |t|
      t.string :token
      t.string :type
      t.string :provider
      t.string :scope
      t.string :authorizer_type
      t.bigint :authorizer_id
      t.belongs_to :account__company,
                   null: false,
                   foreign_key: { to_table: 'account/companies' }

      t.timestamps
    end
  end
end
