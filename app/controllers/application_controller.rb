class ApplicationController < ActionController::Base
  before_action -> { Account::Current.user = current_account_user }
end
