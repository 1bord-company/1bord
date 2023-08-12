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
    end
  end
end
