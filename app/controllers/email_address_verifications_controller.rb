class EmailAddressVerificationsController < ApplicationController
  allow_unauthenticated_access only: %i[ show new create ]

  def show
    # NOTE: リソースの特定は token で行うので id はダミー値がセットされている
    @dummy_id = params[:id]
    @verification = EmailAddressVerification.resolve_token(params[:token])
    @user = User.new(email_address: @verification.email_address)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    raise ActionController::BadRequest, "不正なアカウント登録リンクです"
  end

  def new
  end

  def create
    verification = EmailAddressVerification.new(email_address: params[:email_address])
    unless verification.valid?
      redirect_to "/sign_up", alert: "入力したメールアドレスが不正、または登録済みです" and return
    end

    token, token_expires_at = verification.generate_token
    dummy_id = SecureRandom.uuid # NOTE: リソースの特定は token で行うので id はダミー値をセットする

    AccountMailer.sign_up(verification.email_address, dummy_id, token, token_expires_at).deliver_later

    redirect_to "/sign_up", notice: "アカウント登録用のメールを送信しました"
  end
end
