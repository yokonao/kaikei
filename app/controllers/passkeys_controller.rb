class PasskeysController < ApplicationController
  allow_no_company_access only: %i[ create ]

  before_action :set_user, only: %i[ create ]

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

  def set_user
    raise ActiveRecord::RecordNotFound unless params[:user_id] == "current"
    @user = Current.user
  end

  def init_registration
    options = WebAuthn::Credential.options_for_create(
      user: {
        id: @user.webauthn_user_handle,
        name: @user.email_address
      },
      exclude: @user.user_passkeys.pluck(:id)
    )

    session[:creation_challenge] = options.challenge

    render json: options
  end

  def verify_registration
    webauthn_credential = WebAuthn::Credential.from_create(params)

    begin
      webauthn_credential.verify(session[:creation_challenge])

      passkey = @user.user_passkeys.create!(
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
