class CreateXappRedirects < ActiveRecord::Migration[7.0]
  def change
    create_table 'xapp/redirects' do |t|
      t.string :endpoint
      t.jsonb :params
      t.belongs_to :bot,
                   null: false,
                   foreign_key: { to_table: 'xapp/bots' }

      t.timestamps
    end
  end
end
