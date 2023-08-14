class Core::Resource < Core::Entity
  belongs_to :account__holder,
             class_name: 'Account::Company'
end
