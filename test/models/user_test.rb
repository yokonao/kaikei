require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "webauthn_user_handle should be set automatically" do
    user = User.create!(email_address: "test+123@example.com")

    assert user.webauthn_user_handle.present?
  end

  test "should be valid with valid email address" do
    user = User.new(email_address: "test@example.com")

    assert_nothing_raised { user.validate! }
  end

  test "should be invalid wihtout email address" do
    user = User.new

    assert_not user.valid?
    assert_includes user.errors.full_messages, "メールアドレスを入力してください"
  end

  test "should be invalid with too long email address" do
    user = User.new(email_address: "#{"a" * 256}@example.com")

    assert_not user.valid?
    assert_includes user.errors.full_messages, "メールアドレスは254文字以内で入力してください"
  end

  test "should be invalid with invalid email address" do
    user = User.new(email_address: "invalid")

    assert_not user.valid?
    assert_includes user.errors.full_messages, "メールアドレスの形式が正しくありません"
  end

  test "should be invalid with duplicated email address" do
    email_address = "duplicate@example.com"
    User.create(email_address: email_address)
    user = User.new(email_address: email_address)

    assert_not user.valid?
    assert_includes user.errors.full_messages, "メールアドレスは登録済みです"
  end
end
