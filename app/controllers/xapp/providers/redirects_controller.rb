module Xapp::Providers
  class RedirectsController < ApplicationController
    before_action :authenticate_account_user!

    def new
      uri = URI(request.url)
      @redirect = Xapp::Redirect.find_or_create_by!(
        account__company: Account::Current.company,
        endpoint: uri.path,
        params: Hash[URI.decode_www_form(uri.query)]
      )

      "Xapp::Redirect::#{params[:provider_id]}Handler"
        .constantize.handle @redirect

      redirect_to action: :show, id: @redirect.id
    end
  end
end
