class CreateIntegrationRedirects < ActiveRecord::Migration[7.0]
  def change
    create_table 'integration/redirects' do |t|
      t.string :endpoint
      t.jsonb :params
      t.belongs_to :installation,
                   null: false,
                   foreign_key: { to_table: 'integration/installations' }

      t.timestamps
    end
  end
end
