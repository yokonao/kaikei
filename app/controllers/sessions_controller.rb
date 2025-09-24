class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    redirect_to root_path and return if authenticated?
    @login_method = params[:login_method] || "otp"
  end

  def create
    case params[:login_method]
    when "otp"
      user = User.find_by(email_address: params[:email_address])
      fail_login and return unless user
      session[:otp_user_id] = user.id

      otp = SecureRandom.alphanumeric(8)
      Rails.logger.debug "otp: #{otp}"
      user.user_one_time_passwords.create!(password: otp, expires_at: Time.current + 5.minutes)

      redirect_to new_session_path(login_method: "otp_verification"), notice: "ワンタイムパスワードを #{user.email_address} に送信しました。"
    when "otp_verification"
      user_id = session[:otp_user_id]
      user = User.find_by(id: user_id)
      fail_login and return unless user_id and user

      if UserOneTimePassword.authenticate_otp(user_id, params[:otp])
        start_new_session_for user
        redirect_to after_authentication_url
      else
        fail_login
      end
    else
      user = User.find_by(email_address: params[:email_address])
      fail_login and return unless user

      if UserBasicPassword.authenticate_by(user_id: user.id, password: params[:password])
        start_new_session_for user
        redirect_to after_authentication_url
      else
        fail_login
      end
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def fail_login
    redirect_to new_session_path, alert: "ログインに失敗しました"
  end
end
