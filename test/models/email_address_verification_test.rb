require "test_helper"

class EmailAddressVerificationTest < ActiveSupport::TestCase
  test "should generate and resolve token" do
    email = "test@example.com"
    verification = EmailAddressVerification.new(email_address: email)
    token = verification.generate_token

    assert_not_nil token

    resolved_verification = EmailAddressVerification.resolve_token(token)
    assert_equal email, resolved_verification.email_address
  end

  test "should raise an error if the token is expired" do
    email = "test@example.com"
    verification = EmailAddressVerification.new(email_address: email)
    token = verification.generate_token

    travel_to(EmailAddressVerification::VERIFICATION_TOKEN_EXPIRES_IN.from_now + 1.second) do
      assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
        EmailAddressVerification.resolve_token(token)
      end
    end
  end

  test "should raise an error if the token is invalid" do
    assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
      EmailAddressVerification.resolve_token("invalid_token")
    end
  end
end
