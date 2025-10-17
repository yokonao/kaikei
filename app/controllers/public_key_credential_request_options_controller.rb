class PublicKeyCredentialRequestOptionsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]

  def show
    options = WebAuthn::Credential.options_for_get

    session[:authentication_challenge] = options.challenge

    render json: options
  end
end
