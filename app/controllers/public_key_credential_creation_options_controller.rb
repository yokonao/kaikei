class PublicKeyCredentialCreationOptionsController < ApplicationController
  allow_no_company_access only: %i[ show ]

  def show
    user = target_user
    options = WebAuthn::Credential.options_for_create(
      authenticator_selection: {
        require_resident_key: true,
        resident_key: "required"
      },
      exclude: user.user_passkeys.pluck(:id),
      user: {
        id: user.webauthn_user_handle,
        name: user.email_address
      },
    )

    session[:creation_challenge] = options.challenge

    render json: options
  end
end
