class CreateExtTokens < ActiveRecord::Migration[7.0]
  def change
    create_table 'ext/tokens' do |t|
      t.string :token
      t.string :type
      t.string :provider
      t.string :scope
      t.string :authorizer_type
      t.bigint :authorizer_id
      t.timestamp :expires_at
      t.string :refresh_token

      t.timestamps
    end
  end
end
