class CreateCorePersonas < ActiveRecord::Migration[7.0]
  def change
    create_table 'core/personas' do |t|
      t.string :name
      t.string :external_type
      t.string :external_id
      t.string :provider
      t.belongs_to :account__person,
                   null: false,
                   foreign_key: { to_table: 'account/people' }
      t.jsonb :external_data

      t.timestamps
    end
  end
end
