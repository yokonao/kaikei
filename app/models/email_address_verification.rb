class EmailAddressVerification
  VERIFICATION_TOKEN_EXPIRES_IN = 10.minutes

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email_address, :string

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
end
