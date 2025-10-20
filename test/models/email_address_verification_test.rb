require "test_helper"

class EmailAddressVerificationTest < ActiveSupport::TestCase
  test "should generate and resolve token" do
    email = "test@example.com"
    verification = EmailAddressVerification.new(email_address: email)
    token, _ = verification.generate_token

    assert_not_nil token

    resolved_verification = EmailAddressVerification.resolve_token(token)
    assert_equal email, resolved_verification.email_address
  end

  test "should raise an error if the token is expired" do
    email = "test@example.com"
    verification = EmailAddressVerification.new(email_address: email)
    token, _ = verification.generate_token

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

  # validation
  test "should be valid with valid email_address" do
    verification = EmailAddressVerification.new(email_address: "valid@example.com")
    assert_nothing_raised { verification.validate! }
  end

  test "should be invalid without email_address" do
    verification = EmailAddressVerification.new
    assert_not verification.valid?
    assert_includes verification.errors.full_messages, "メールアドレスを入力してください"
  end

  test "should be invalid with invalid format email_address" do
    verification = EmailAddressVerification.new(email_address: "invalid")
    assert_not verification.valid?
    assert_includes verification.errors.full_messages, "メールアドレスの形式が正しくありません"
  end

  test "should be invalid when an existing user uses the email_address" do
    User.create!(email_address: "test+already-existing@example.com")
    verification = EmailAddressVerification.new(email_address: "test+already-existing@example.com")
    assert_not verification.valid?
    assert_includes verification.errors.full_messages, "このメールアドレスは登録済みです"
  end
end
