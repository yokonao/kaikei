class AccountMailer < ApplicationMailer
  default from: "Invitation <auto@kaikei.yokonao.xyz>"

  def sign_up(email_address, dummy_id, token, expires_at)
    @email_address = email_address
    @url = email_address_verification_url(dummy_id, token: token)
    @expires_at = expires_at
    mail subject: "KAIKEI アカウント登録リンク", from: "Sign Up <auto@kaikei.yokonao.xyz>", to: email_address
  end
end
