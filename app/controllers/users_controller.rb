class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  allow_no_company_access only: %i[ show destroy ]

  before_action :set_user, only: %i[ show destroy ]

  def new
    @user = User.new
  end

  def show
  end

  def create
    user = User.find_or_create_by(user_params)
    session[:otp_user_id] = user.id
    user.create_otp!
    redirect_to new_session_path(login_method: "otp_verification"), notice: "ワンタイムパスワードを #{user.email_address} に送信しました。"
  end

  def destroy
    terminate_session
    DestroyUserJob.perform_later(user_id: @user.id)

    redirect_to new_session_path, notice: "アカウント（#{@user.email_address}）を削除しました。"
  end

  private

  def user_params
    params.require(:user).permit(:email_address)
  end

  def set_user
    raise ActiveRecord::RecordNotFound unless params[:id] == "current"
    @user = Current.user
  end
end
