class Ext::Resource < Ext::Entity
  has_many :roles

  belongs_to :account__company,
             polymorphic: true,
             foreign_key: :account__holder_id,
             foreign_type: :account__holder_type

  has_many :account__audits,
           as: :auditee

  has_and_belongs_to_many :personas,
                          join_table: 'ext/roles'
end
