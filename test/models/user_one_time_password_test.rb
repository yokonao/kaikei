require "test_helper"

class UserOneTimePasswordTest < ActiveSupport::TestCase
  test "should be valid with user, password and expires_at" do
    user = users(:one)
    one_time_password = user.build_user_one_time_password(
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
    one_time_password = user.build_user_one_time_password(
      expires_at: 1.hour.from_now
    )

    assert_not one_time_password.valid?
    assert_includes one_time_password.errors.full_messages, "パスワードを入力してください"
  end

  test "should be invalid without expires_at" do
    user = users(:one)
    one_time_password = user.build_user_one_time_password(
      password: "password"
    )

    assert_not one_time_password.valid?
    assert_includes one_time_password.errors.full_messages, "有効期限を入力してください"
  end

  class AuthenticateOTPTest < ActiveSupport::TestCase
    test "should return true and destroy the record for a valid OTP" do
      user = users(:one)
      otp = "123456"
      one_time_password = user.create_user_one_time_password!(
        password: otp,
        expires_at: 1.hour.from_now
      )

      assert_difference("UserOneTimePassword.count", -1) do
        assert UserOneTimePassword.authenticate_otp(user.id, otp)
      end
      assert_not UserOneTimePassword.authenticate_otp(user.id, otp) # The second time the authentication fails
    end

    test "should overwrite old otp" do
      user = users(:one)

      user.create_user_one_time_password!(password: "old_otp", expires_at: 1.hour.from_now)

      # create_user_one_time_password! will raise an error, so we need to use update!
      user.user_one_time_password.update!(password: "new_otp", expires_at: 1.hour.from_now)

      assert_not UserOneTimePassword.authenticate_otp(user.id, "old_otp")
      assert UserOneTimePassword.authenticate_otp(user.id, "new_otp")
    end

    test "should return false for a non-existent OTP" do
      user = users(:one)
      assert_not UserOneTimePassword.authenticate_otp(user.id, "123456")
    end

    test "should return false for an invalid OTP" do
      user = users(:one)
      otp = "123456"
      one_time_password = user.create_user_one_time_password!(
        password: otp,
        expires_at: 1.hour.from_now
      )

      assert_no_difference("UserOneTimePassword.count") do
        assert_not UserOneTimePassword.authenticate_otp(user.id, "wrong-otp")
      end
    end

    test "should return false for an expired OTP" do
      user = users(:one)
      otp = "123456"
      one_time_password = user.create_user_one_time_password!(
        password: otp,
        expires_at: 1.hour.ago
      )

      assert_no_difference("UserOneTimePassword.count") do
        assert_not UserOneTimePassword.authenticate_otp(user.id, otp)
      end
    end
  end
end
