class InvitationMailer < ApplicationMailer
  default from: "Invitation <auto@kaikei.yokonao.xyz>"

  def invite(invitation, dummy_id, token, expires_at)
    @invitation = invitation
    @url = invitation_url(dummy_id, token: token)
    @expires_at = expires_at
    mail subject: "KAIKEI 招待リンク", to: @invitation.email_address
  end
end
