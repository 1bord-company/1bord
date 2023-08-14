class Core::Resource < Core::Entity
  belongs_to :account__company,
             class_name: 'Account::Company'
end
