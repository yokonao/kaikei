module Users
  class PasswordsController < ApplicationController
    def update
      @user = Current.user

      challenge = user_password_params[:password_challenge]
      password_attributes = user_password_params.except(:password_challenge)

      @user_basic_password = @user.user_basic_password || @user.build_user_basic_password

      if @user_basic_password.persisted?
        unless @user_basic_password.authenticate(challenge)
          @user_basic_password.errors.add(:password_challenge, "が正しくありません")
          return render "users/show", status: :unprocessable_entity
        end
      end

      if @user_basic_password.update(password_attributes)
        redirect_to user_path, notice: "パスワードを変更しました。"
      else
        render "users/show", status: :unprocessable_entity
      end
    end

    private

    def user_password_params
      params.require(:user_basic_password).permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
    end
  end
end
