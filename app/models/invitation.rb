class Invitation < ApplicationRecord
  belongs_to :company

  INVITATION_TOKEN_EXPIRES_IN = 1.days
  generates_token_for :invitation, expires_in: INVITATION_TOKEN_EXPIRES_IN

  validates :email_address, presence: true,
          length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
          uniqueness: { scope: :company_id, message: "は招待済みです" },
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
  validates :inviter_email_address, presence: true,
          length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }

  validate :validate_membership_does_not_exists

  def self.accept!(record)
    ActiveRecord::Base.transaction do
      @user = User.find_or_create_by!(email_address: record.email_address)
      Membership.create!(user_id: @user.id, company_id: record.company_id)

      # NOTE: 招待受諾と同時に、同じ事業所・同じメールアドレス宛の招待は全て無効になる
      Invitation.where(company_id: record.company_id, email_address: record.email_address).destroy_all
    end
  end

  def user
    @user || User.find_by(email_address: self.email_address)
  end

  def send_mail
    token = self.generate_token_for(:invitation)
    # 生成したトークンから有効期限を取得する安全な方法はないので推定値を利用する
    token_expires_at = Time.current + Invitation::INVITATION_TOKEN_EXPIRES_IN
    # NOTE: リソースの特定は token で行うので id はダミー値をセットする
    dummy_id = SecureRandom.uuid

    InvitationMailer.invite(self, dummy_id, token, token_expires_at).deliver_later
  end

  private

  def validate_membership_does_not_exists
    if Membership.joins(:user).where("user.email_address": self.email_address, company_id: self.company_id).exists?
      errors.add(:email_address, "のユーザーは既に事業所のメンバーになっています")
    end
  end
end
