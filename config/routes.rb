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

  {
    git_hub: 'https://github.com/apps/1bord-basic/',
    slack: 'https://slack.com/apps/A05FDCGGTGS-1bord-basic'
  }.each { |key, url| direct key do url end }
end
