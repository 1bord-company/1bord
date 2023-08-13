Rails.application.routes.draw do
  devise_for 'account/users',
             class_name: 'Account::User',
             controllers: {
               registrations: 'account/users/registrations'
             }

  root 'account/companies#show'

  namespace :xapp do
    resources :providers, only: [] do
      scope module: :providers do
        resources :redirects, only: :new
      end
    end
  end
end
