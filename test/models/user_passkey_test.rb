require "test_helper"

class UserPasskeyTest < ActiveSupport::TestCase
  test "can create with valid attributes" do
    user = users(:one)
    user_passkey = UserPasskey.new(
      id: SecureRandom.alphanumeric(24),
      user: user,
      display_name: "Passkey Name",
      public_key: "public_key",
      sign_count: 0,
      aaguid: "00000000-0000-0000-0000-000000000000"
    )
    assert_nothing_raised { user_passkey.save! }
  end

  test "can create without aaguid" do
    user = users(:one)
    user_passkey = UserPasskey.new(
      id: SecureRandom.alphanumeric(24),
      user: user,
      display_name: "Passkey Name",
      public_key: "public_key",
      sign_count: 0,
    )
    assert_nothing_raised { user_passkey.save! }
    assert_equal "00000000-0000-0000-0000-000000000000", user_passkey.aaguid
  end

  test "should be invalid wihtout id" do
    user = users(:one)
    user_passkey = UserPasskey.new(user: user, display_name: "Chrome on Mac",public_key: "public_key", sign_count: 0)
    error = assert_raises { user_passkey.save! }
    assert_equal ActiveRecord::NotNullViolation, error.class
  end

  test "should be invalid without user" do
    user_passkey = UserPasskey.new(id: SecureRandom.alphanumeric(24), display_name: "Chrome on Mac", public_key: "public_key", sign_count: 0)
    assert_not user_passkey.valid?
    assert_includes user_passkey.errors.full_messages, "ユーザーを入力してください"
  end

  test "should be invalid without display_name" do
    user = users(:one)
    user_passkey = UserPasskey.new(id: SecureRandom.alphanumeric(24), user: user, public_key: "public_key", sign_count: 0)
    assert_not user_passkey.valid?
    assert_includes user_passkey.errors.full_messages, "表示名を入力してください"
  end

  test "should be invalid without public_key" do
    user = users(:one)
    user_passkey = UserPasskey.new(id: SecureRandom.alphanumeric(24), user: user, display_name: "Chrome on Mac", sign_count: 0)
    assert_not user_passkey.valid?
    assert_includes user_passkey.errors.full_messages, "公開鍵を入力してください"
  end

  test "should be invalid without sign_count" do
    user = users(:one)
    user_passkey = UserPasskey.new(id: SecureRandom.alphanumeric(24), user: user, display_name: "Chrome on Mac", public_key: "public_key")
    assert_not user_passkey.valid?
    assert_includes user_passkey.errors.full_messages, "サインカウントを入力してください"
  end
end
