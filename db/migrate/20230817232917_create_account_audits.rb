class CreateAccountAudits < ActiveRecord::Migration[7.0]
  def change
    create_table 'account/audits' do |t|
      t.bigint :auditor_id
      t.string :auditor_type
      t.bigint :auditee_id
      t.string :auditee_type

      t.timestamps
    end
  end
end
