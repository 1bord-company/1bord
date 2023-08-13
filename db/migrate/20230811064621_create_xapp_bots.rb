class CreateXappBots < ActiveRecord::Migration[7.0]
  def change
    create_table 'xapp/bots' do |t|
      t.string :provider
      t.string :external_id
      t.belongs_to :redirect,
                   null: false,
                   foreign_key: { to_table: 'xapp/redirects' },
                   index: { unique: true }
      t.jsonb :external_data

      t.timestamps
    end

    add_index 'xapp/bots', [:provider, :external_id], unique: true
  end
end
