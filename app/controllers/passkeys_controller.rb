class PasskeysController < ApplicationController
  allow_no_company_access only: %i[ create destroy ]

  before_action :set_user, only: %i[ create destroy ]
  before_action :set_passkey, only: %i[ destroy ]

  def create
    webauthn_credential = WebAuthn::Credential.from_create(params)

    begin
      webauthn_credential.verify(session[:creation_challenge])

      passkey = @user.user_passkeys.build(
        id: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count,
        aaguid: webauthn_credential.response.aaguid
      )
      passkey.autofill_display_name!
      passkey.save!

      render json: { status: "ok" }, status: :ok
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unprocessable_content
    ensure
      session.delete(:creation_challenge)
    end
  end

  def destroy
    @passkey.destroy!
    sync_passkeys
    redirect_to user_path(id: @user.id), notice: "パスキーを削除しました。"
  end

  private

  def set_passkey
    @passkey = @user.user_passkeys.find(params[:id])
  end

  def set_user
    @user = target_user
  end
end
