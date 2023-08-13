class CreateXappRedirects < ActiveRecord::Migration[7.0]
  def change
    create_table 'xapp/redirects' do |t|
      t.string :endpoint
      t.jsonb :params

      t.belongs_to :account__company,
                   null: false,
                   foreign_key: { to_table: 'account/companies' }

      t.timestamps
    end

    add_index 'xapp/redirects',
              %i[account__company_id endpoint params],
              unique: true,
              name: 'idx-x/rdrs_on(a/comp_id,endpoint,params)'
  end
end
