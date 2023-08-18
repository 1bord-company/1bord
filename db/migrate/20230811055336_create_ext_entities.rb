class CreateExtEntities < ActiveRecord::Migration[7.0]
  def change
    create_table 'ext/entities' do |t|
      t.string :name
      t.string :type
      t.string :external_type
      t.string :external_id
      t.string :provider
      t.string :account__holder_type
      t.bigint :account__holder_id
      t.jsonb :external_data,
              default: {}

      t.timestamps
    end
  end
end
