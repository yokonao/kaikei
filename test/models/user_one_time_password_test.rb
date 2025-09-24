require "test_helper"

class UserOneTimePasswordTest < ActiveSupport::TestCase
  test "should be valid with user, password and expires_at" do
    user = users(:one)
    one_time_password = user.user_one_time_passwords.build(
      password: "password",
      expires_at: 1.hour.from_now
    )

    assert_nothing_raised { one_time_password.validate! }
  end

  test "should be invalid without user" do
    one_time_password = UserOneTimePassword.new(
      password: "password",
      expires_at: 1.hour.from_now
    )

    assert_not one_time_password.valid?
    assert_includes one_time_password.errors.full_messages, "ユーザーを入力してください"
  end

  test "should be invalid without password" do
    user = users(:one)
    one_time_password = user.user_one_time_passwords.build(
      expires_at: 1.hour.from_now
    )

    assert_not one_time_password.valid?
    assert_includes one_time_password.errors.full_messages, "パスワードを入力してください"
  end

  test "should be invalid without expires_at" do
    user = users(:one)
    one_time_password = user.user_one_time_passwords.build(
      password: "password"
    )

    assert_not one_time_password.valid?
    assert_includes one_time_password.errors.full_messages, "有効期限を入力してください"
  end
end
