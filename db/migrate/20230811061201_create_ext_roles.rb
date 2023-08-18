class CreateExtRoles < ActiveRecord::Migration[7.0]
  def change
    create_table 'ext/roles' do |t|
      t.string :name
      t.string :provider
      t.belongs_to :resource,
                   null: false,
                   foreign_key: { to_table: 'ext/entities' }
      t.belongs_to :persona,
                   null: false,
                   foreign_key: { to_table: 'ext/entities' }
      t.timestamp :onboard_at
      t.timestamp :onboarded_at
      t.timestamp :offboard_at
      t.timestamp :offboarded_at

      t.timestamps
    end
  end
end
