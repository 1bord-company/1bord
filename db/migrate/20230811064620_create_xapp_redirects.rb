class CreateXappRedirects < ActiveRecord::Migration[7.0]
  def change
    create_table 'xapp/redirects' do |t|
      t.string :endpoint
      t.jsonb :params

      t.timestamps
    end

    add_index 'xapp/redirects',
              %i[endpoint params],
              unique: true
  end
end
