module Account
  class CompaniesController < ApplicationController
    def show
      @company = Account::Current.company
      @ext__tokens = @company.ext__tokens
    end
  end
end
