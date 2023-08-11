class CreateIntegrationAuthorizations < ActiveRecord::Migration[7.0]
  def change
    create_table 'integration/authorizations' do |t|
      t.string :token
      t.string :type
      t.belongs_to :installation,
                   null: false,
                   foreign_key: { to_table: 'integration/installations' }
      t.belongs_to :redirect,
                   null: false,
                   foreign_key: { to_table: 'integration/redirects' }

      t.timestamps
    end
  end
end
