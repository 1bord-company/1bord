class CreateAccountPeople < ActiveRecord::Migration[7.0]
  def change
    create_table 'account/people' do |t|
      t.string :name
      t.string :email
      t.belongs_to :company, null: false, foreign_key: { to_table: 'account/companies' }

      t.timestamps
    end
  end
end
