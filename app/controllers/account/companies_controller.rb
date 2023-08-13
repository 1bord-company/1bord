module Account
  class CompaniesController < ApplicationController
    def show
      @company = Account::Current.company
      @sync__tokens = @company.sync__tokens
    end
  end
end
