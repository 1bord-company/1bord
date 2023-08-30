class CreateExtTokens < ActiveRecord::Migration[7.0]
  def change
    create_table 'ext/tokens' do |t|
      t.string :access_token
      t.string :type
      t.string :provider
      t.string :scope
      t.string :authorizer_type
      t.bigint :authorizer_id
      t.timestamp :expires_at
      t.string :refresh_token

      t.timestamps
    end

    add_index 'ext/tokens',
              [:provider, :authorizer_type, :authorizer_id],
              unique: true,
              where: "authorizer_type = 'Ext::Bot'",
              name: 'idx_ext/tkns[provider,authorizer]'
  end
end
