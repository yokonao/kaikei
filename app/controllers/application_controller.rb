class ApplicationController < ActionController::Base
  include Authentication

  def sync_passkeys
    flash[:will_sync_passkeys] = true
  end
end
