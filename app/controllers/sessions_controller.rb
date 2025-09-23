class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    fail_login and return unless user
    if UserBasicPassword.authenticate_by(user_id: user.id, password: params[:password])
      start_new_session_for user
      redirect_to after_authentication_url
    else
      fail_login
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def fail_login
    redirect_to new_session_path, alert: "Try another email address or password."
  end
end
