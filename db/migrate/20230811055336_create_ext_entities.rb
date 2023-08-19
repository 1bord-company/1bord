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

    add_index 'ext/entities',
              %i[external_type external_id
                 provider
                 account__holder_id account__holder_type],
              unique: true,
              name: 'inx_ext/ents[ext_typ,ext_id,prov,acc__hldr_id,acc__hldr_typ]'
  end
end
