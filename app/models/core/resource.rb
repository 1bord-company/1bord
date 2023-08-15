class Core::Resource < Core::Entity
  has_many :roles

  has_and_belongs_to_many :personas,
                          join_table: 'core/roles'
end
