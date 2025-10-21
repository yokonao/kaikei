class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ create ]
  allow_no_company_access only: %i[ show destroy ]

  before_action :set_user, only: %i[ show destroy ]

  def show
  end

  def create
    user = User.create!(user_params)
    start_new_session_for user
    redirect_to companies_path, notice: "アカウント登録が完了しました"
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
    @user = target_user
  end

  def target_user
    @target_user ||= User.where(id: Current.user&.id).find(params[:id])
  end
end
