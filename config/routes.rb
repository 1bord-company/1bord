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

  namespace :xapp, shallow: true do
    resources :providers, only: [] do
      scope module: :providers do
        resources :redirects, only: %i[new show]
      end
    end
  end

  host_url = Rails.application.credentials.host_url
  client_ids = Rails.application.credentials.providers
                    .map { |provider, data| [provider, data.app.client_id] }
                    .to_h
  {
    git_hub: "https://github.com/apps/#{Rails.application.credentials.providers.git_hub.app.slug}/installations/select_target",
    slack: "https://slack.com/apps/#{Rails.application.credentials.providers.slack.app.id}",
    jira: "https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=#{client_ids[:jira]}&scope=read%3Ajira-user%20offline_access&redirect_uri=#{host_url}/xapp/providers/Jira/redirects/new&state=${YOUR_USER_BOUND_VALUE}&response_type=code&prompt=consent",
    heroku: "https://id.heroku.com/oauth/authorize?client_id=#{client_ids[:heroku]}&response_type=code&scope=global&state={anti-forgery-token}",
    google: "https://accounts.google.com/o/oauth2/auth?client_id=#{client_ids[:google]}&response_type=code&redirect_uri=#{host_url}/xapp/providers/Google/redirects/new&scope=https://www.googleapis.com/auth/admin.directory.user.readonly&access_type=offline",
    asana: "https://app.asana.com/-/oauth_authorize?response_type=code&client_id=#{client_ids[:asana]}&redirect_uri=#{host_url}/xapp/providers/Asana/redirects/new&state=<STATE_PARAM>"
  }.each { |key, url| direct key do url end }
end
