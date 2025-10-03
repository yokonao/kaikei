class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    redirect_to root_path and return if authenticated?
    @login_method = params[:login_method]
  end

  def create
    @login_method = params[:login_method]
    case @login_method
    when "otp"
      init_otp
    when "otp_verification"
      verify_otp
    when "passkey"
      passkey_auth
    when "dev"
      raise "unknown login method #{@login_method}" unless Rails.env.development?
      dev_auth
    else
      raise "unknown login method #{@login_method}"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def init_otp
    user = User.find_by(email_address: params[:email_address])
    fail_login and return unless user

    session[:otp_user_id] = user.id
    user.create_otp!

    redirect_to new_session_path(login_method: "otp_verification"), notice: "ワンタイムパスワードを #{user.email_address} に送信しました。"
  end

  def verify_otp
    user_id = session[:otp_user_id]
    user = User.find_by(id: user_id)
    fail_login and return unless user_id and user

    if UserOneTimePassword.authenticate_otp(user_id, params[:otp])
      success_login user
    else
      fail_login
    end
  end

  def passkey_auth
    phase = params[:phase]
    raise "phase must be initiation or verification" unless phase == "initiation" || phase == "verification"

    case phase
    when "initiation"
      passkey_auth_init
    when "verification"
      passkey_auth_verify
    end
  end

  def passkey_auth_init
    options = WebAuthn::Credential.options_for_get

    session[:authentication_challenge] = options.challenge

    render json: options
  end

  def passkey_auth_verify
    webauthn_credential = WebAuthn::Credential.from_get(params)

    passkey = UserPasskey.find_by(id: webauthn_credential.id)
    if passkey.nil?
      render json: { error: "Passkey not found" }, status: :not_found
      return
    end

    begin
      webauthn_credential.verify(
        session[:authentication_challenge],
        public_key: passkey.public_key,
        sign_count: passkey.sign_count
      )

      passkey.update!(sign_count: webauthn_credential.sign_count)
      start_new_session_for(passkey.user)

      render json: { status: "ok", redirect_url: after_authentication_url }, status: :ok
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unprocessable_content
    ensure
      session.delete(:authentication_challenge)
    end
  end

  def dev_auth
    user = User.first
    company = user.companies.first
    success_login User.first, company: company
  end

  def success_login(user, company: nil)
    start_new_session_for user, company: company
    if Current.session.company.present?
      redirect_to after_authentication_url
    else
      redirect_to companies_path
    end
  ensure
    session.delete(:otp_user_id)
  end

  def fail_login
    redirect_to new_session_path(login_method: @login_method), alert: "ログインに失敗しました"
  end
end
