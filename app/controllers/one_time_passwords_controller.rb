class OneTimePasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[ create ]

  def create
    user = User.find_by(email_address: params[:email_address])
    redirect_to new_session_path, alert: "ログインに失敗しました" and return unless user

    session[:otp_user_id] = user.id
    user.create_otp!

    redirect_to new_session_path(login_method: "otp"), notice: "ワンタイムパスワードを #{user.email_address} に送信しました。"
  end
end
