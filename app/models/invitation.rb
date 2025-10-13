class Invitation < ApplicationRecord
  belongs_to :company

  INVITATION_TOKEN_EXPIRES_IN = 1.days
  generates_token_for :invitation, expires_in: INVITATION_TOKEN_EXPIRES_IN

  validates :email_address, presence: true,
          length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
  validates :inviter_email_address, presence: true,
          length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }

  def accept!
    return if self.accepted?

    ActiveRecord::Base.transaction do
      @user = User.find_or_create_by!(email_address: self.email_address)
      Membership.create!(user_id: @user.id, company_id: self.company_id)
      self.update!(accepted: true)
    end
  end

  def user
    @user || User.find_by(email_address: self.email_address)
  end
end
