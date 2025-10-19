class EmailAddressVerificationsController < ApplicationController
  allow_unauthenticated_access only: %i[ show new create ]

  def show
    # NOTE: リソースの特定は token で行うので id はダミー値がセットされている
    @dummy_id = params[:id]
    @verification = EmailAddressVerification.resolve_token(params[:token])
    @user = User.new(email_address: @verification.email_address)
  end

  def new
  end

  def create
    verification = EmailAddressVerification.new(email_address: params[:email_address])
    unless verification.valid?
      redirect_to "/signup", alert: "入力したメールアドレスが不正、または登録済みです" and return
    end

    token = verification.generate_token
    # 生成したトークンから有効期限を取得する方法がわからないので推定値を利用する
    # TODO: よりよい方法がないか調査する
    token_expires_at = Time.current + EmailAddressVerification::VERIFICATION_TOKEN_EXPIRES_IN
    # NOTE: リソースの特定は token で行うので id はダミー値をセットする
    dummy_id = SecureRandom.uuid

    AccountMailer.sign_up(verification.email_address, dummy_id, token, token_expires_at).deliver_later

    redirect_to "/signup", notice: "アカウント登録用のメールを送信しました"
  end
end
