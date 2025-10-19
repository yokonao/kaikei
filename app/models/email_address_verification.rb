class EmailAddressVerification
  VERIFICATION_TOKEN_EXPIRES_IN = 10.minutes

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :email_address, :string

  validates :email_address, presence: true,
          length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
  validate :validate_email_address_not_registered

  delegate :message_verifier, :message_verifier_purpose, to: :class

  def generate_token
    payload = [ self.email_address ]
    self.message_verifier.generate(payload, expires_in: VERIFICATION_TOKEN_EXPIRES_IN, purpose: self.message_verifier_purpose)
  end

  def self.resolve_token(token)
    payload = self.message_verifier.verify(token, purpose: self.message_verifier_purpose)
    raise ActiveSupport::MessageVerifier::InvalidSignature if payload.blank?
    self.new(email_address: payload[0])
  end

  private

  def self.message_verifier
    Rails.application.message_verifier("application_model/email_address_verification")
  end

  def self.message_verifier_purpose
    self.name
  end

  def validate_email_address_not_registered
    if User.where(email_address: self.email_address).exists?
      errors.add(:base, "このメールアドレスは登録済みです")
    end
  end
end
