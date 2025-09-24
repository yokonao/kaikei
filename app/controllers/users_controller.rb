class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    user = User.find_or_create_by(user_params)
    user.user_one_time_passwords.create!(password: "123456", expires_at: Time.zone.now + 10.minutes)
    # TODO: メール送信
    redirect_to new_session_path
  end

  private
    def user_params
      params.require(:user).permit(:email_address)
    end
end
