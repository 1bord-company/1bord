module Xapp::Providers
  class RedirectsController < ApplicationController
    def new
      uri = URI(request.url)
      @redirect = Xapp::Redirect.find_or_create_by!(
        endpoint: uri.path,
        params: Hash[URI.decode_www_form(uri.query)]
      )

      client =
        "Providers::#{params[:provider_id]}::UserAccessTokenClient".constantize
      token_info = client.create(code: params['code'])

      @bot = Xapp::Bot.find_or_create_by!(
        redirect: @redirect,
        external_id: params[:installation_id] || token_info['external_id'],
        provider: params[:provider_id]
      )

      @token = Sync::Token.create!(
        authorizer: @bot,
        provider: params[:provider_id],
        scope: token_info['scope'],
        token: token_info['access_token']
      )
    end
  end
end
