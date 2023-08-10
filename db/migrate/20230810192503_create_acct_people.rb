class CreateAcctPeople < ActiveRecord::Migration[7.0]
  def change
    create_table 'acct/people' do |t|
      t.string :name
      t.string :email
      t.belongs_to :company, null: false, foreign_key: { to_table: 'acct/companies' }

      t.timestamps
    end
  end
end
