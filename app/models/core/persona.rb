class Core::Persona < Core::Entity
  has_many :roles

  has_and_belongs_to_many :resources,
                           join_table: 'core/roles'
end
