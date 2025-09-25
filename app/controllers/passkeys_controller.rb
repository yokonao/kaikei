class PasskeysController < ApplicationController
  def create
    phase = params[:phase]
    raise "phase must be initiation or verification" unless phase == "initiation" || phase == "verification"

    case phase
    when "initiation"
      init_registration
    when "verification"
      verify_registration
    end
  end

  private

  def init_registration
    user = Current.user
    options = WebAuthn::Credential.options_for_create(
      user: {
        id: user.webauthn_user_handle,
        name: user.email_address
      },
      exclude: user.user_passkeys.pluck(:id)
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
