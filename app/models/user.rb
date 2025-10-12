class User < ApplicationRecord
  has_one :user_one_time_password, dependent: :destroy
  has_many :user_passkeys, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :companies, through: :memberships

  validates :email_address, presence: true,
            uniqueness: { message: "は登録済みです" },
            length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  before_create :set_webauthn_user_handle

  def create_otp!
    otp = SecureRandom.alphanumeric(8)
    # NOTE: 開発環境では OTP を確認しやすいようにデバッグログに出力
    Rails.logger.debug "otp: #{otp}" if Rails.env.development?
    OtpMailer.otp_login(self, otp).deliver_later
    otp_record = self.user_one_time_password || self.build_user_one_time_password
    otp_record.update!(password: otp, expires_at: Time.current + 5.minutes)
  end

  def set_webauthn_user_handle
    self.webauthn_user_handle = WebAuthn.generate_user_id
  end

  def incinerate!
    User::Incineration.new(self).run
  end

  def exit!(company)
    ActiveRecord::Base.transaction do
      exit = User::Exit.new(self, company)
      exit.run
    end
  end
end
