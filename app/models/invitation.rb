class Invitation < ApplicationRecord
  belongs_to :company

  generates_token_for :invitation, expires_in: 1.days

  validates :email_address, presence: true,
          length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
  validates :inviter_email_address, presence: true,
          length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
end
