class CreateCoreResources < ActiveRecord::Migration[7.0]
  def change
    create_table 'core/resources' do |t|
      t.string :name
      t.string :external_type
      t.string :external_id
      t.string :provider
      t.belongs_to :account__company,
                   null: false,
                   foreign_key: { to_table: 'account/companies' }
      t.jsonb :external_data,
              default: {}

      t.timestamps
    end
  end
end
