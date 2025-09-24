class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def show
    @user = Current.user
    @user_basic_password = @user.user_basic_password || @user.build_user_basic_password
  end

  def create
    user = User.find_or_create_by(user_params)
    session[:otp_user_id] = user.id
    user.create_otp!
    redirect_to new_session_path(login_method: "otp_verification"), notice: "ワンタイムパスワードを #{user.email_address} に送信しました。"
  end

  private
    def user_params
      params.require(:user).permit(:email_address)
    end
end
