class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      Current.session = @user.sessions.create!
      session[:session_token] = Current.session.token
      redirect_to root_path, notice: "アカウント登録が完了しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:email_address)
    end
end
