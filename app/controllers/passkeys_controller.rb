class PasskeysController < ApplicationController
  allow_unauthenticated_access only: [ :new_authentication, :create_authentication ]

  def create
    phase = params[:phase]
    raise "phase must be initialization or verification" unless phase == "initiation" || phase == "verification"

    case phase
    when "initiation"
      init_registration
    when "verification"
      verify_registration
    end
  end

  def new_authentication
    options = WebAuthn::Credential.options_for_get

    session[:authentication_challenge] = options.challenge

    render json: options
  end

  def create_authentication
    webauthn_credential = WebAuthn::Credential.from_get(params)

    passkey = UserPasskey.find_by(external_id: webauthn_credential.id)
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

  private

  def init_registration
    user = Current.user
    options = WebAuthn::Credential.options_for_create(
      user: {
        id: WebAuthn.generate_user_id, # TODO: webauthn_id にする
        name: user.email_address,
      },
      exclude: user.user_passkeys.pluck(&:id)
    )

    session[:creation_challenge] = options.challenge

    render json: options
  end

  def verify_registration
    webauthn_credential = WebAuthn::Credential.from_create(params)

    begin
      webauthn_credential.verify(session[:creation_challenge])

      passkey = Current.session.user.user_passkeys.create!(
        id: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count
      )

      render json: { status: "ok" }, status: :ok
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unprocessable_content
    ensure
      session.delete(:creation_challenge)
    end
  end
end
