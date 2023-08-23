Rails.application.routes.draw do
  devise_for 'account/users',
             class_name: 'Account::User',
             controllers: {
               registrations: 'account/users/registrations'
             }

  namespace :account do
    resource :audit, only: :create
  end

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
    slack: 'https://slack.com/apps/A05FDCGGTGS-1bord-basic',
    jira: 'https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=we3TCrAJslUROZHxTu1v2xF4HOlxgnwG&scope=read%3Ajira-user%20offline_access&redirect_uri=https%3A%2F%2F8c36-49-37-200-135.ngrok-free.app%2Fxapp%2Fproviders%Jira%2Fredirects%2Fnew&state=${YOUR_USER_BOUND_VALUE}&response_type=code&prompt=consent',
    heroku: 'https://id.heroku.com/oauth/authorize?client_id=156a329a-f734-4e74-9513-831bc3395f87&response_type=code&scope=global&state={anti-forgery-token}',
    google: 'https://accounts.google.com/o/oauth2/auth?client_id=838747206274-2s2d33rkvhociuffev4gkj44iesahkfu.apps.googleusercontent.com&response_type=code&redirect_uri=https://3e07-106-196-18-137.ngrok-free.app/xapp/providers/Google/redirects/new&scope=https://www.googleapis.com/auth/admin.directory.user.readonly&access_type=offline'
  }.each { |key, url| direct key do url end }
end
