Rails.application.routes.draw do
  devise_for 'acct/users', class_name: "Acct::User"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  root "articles#index"
end
