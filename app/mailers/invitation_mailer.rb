class InvitationMailer < ApplicationMailer
  default from: "Invitation <auto@kaikei.yokonao.xyz>"

  def invite(invitation, url, expires_at)
    @invitation = invitation
    @url = url
    @expires_at = expires_at
    mail subject: "KAIKEI 招待リンク", to: @invitation.email_address
  end
end
