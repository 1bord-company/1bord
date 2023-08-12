module Xapp::Providers
  class RedirectsController < ApplicationController
    def new
      @bot = Xapp::Bot.find_or_create_by!(
        external_id: params[:installation_id],
        provider: params[:provider_id],
        account__company: Account::Current.company
      )
      uri = URI(request.url)
      @redirect = Xapp::Redirect.find_or_create_by!(
        bot: @bot,
        endpoint: uri.path,
        params: Hash[URI.decode_www_form(uri.query)]
      )

      client =
        "Providers::#{params[:provider_id]}::UserAccessTokenClient".constantize
      token_info = client.create(code: @redirect.params['code'])
      Sync::Token.create!(
        authorizer: @bot,
        account__company: Account::Current.company,
        provider: params[:provider_id],
        scope: token_info['scope'],
        token: token_info['access_token']
      )
    end
  end
end
