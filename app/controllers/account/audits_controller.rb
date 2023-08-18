module Account
  class AuditsController < ApplicationController
    def create
      Current.company.ext__bots.audit!
      redirect_to root_path
    end
  end
end
