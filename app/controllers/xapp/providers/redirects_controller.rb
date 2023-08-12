module Xapp::Providers
  class RedirectsController < ApplicationController
    def new
      @redirect = Xapp::Redirect.create!(
        bot_attributes: {
          external_id: params[:installation_id],
          provider: params[:provider_id],
          account__company: Account::Current.company
        },
        endpoint: URI(request.url).path
      )
    end
  end
end
