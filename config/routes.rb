Rails.application.routes.draw do
  devise_for 'account/users', class_name: "Account::User",
    controllers: {
      registrations: 'account/users/registrations'
    }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  root "articles#index"

  namespace :xapp do
    resources :providers, only: [] do
      scope module: :providers do
        resources :redirects, only: :new
      end
    end
  end
end
