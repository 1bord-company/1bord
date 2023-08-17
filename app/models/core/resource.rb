class Core::Resource < Core::Entity
  has_many :roles

  belongs_to :account__company,
             class_name: 'Account::Company',
             foreign_key: :account__holder_id

  has_and_belongs_to_many :personas,
                          join_table: 'core/roles'
end
