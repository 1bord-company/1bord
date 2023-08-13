module Account
  class ApplicationController < ::ApplicationController
    before_action :authenticate_account_user!
    before_action :set_account_current_attrs

    private

    def set_account_current_attrs
      Current.user = current_account_user
    end
  end
end
