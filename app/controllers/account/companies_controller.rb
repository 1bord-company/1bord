module Account
  class CompaniesController < ApplicationController
    def show
      @company = Account::Current.company
    end
  end
end
