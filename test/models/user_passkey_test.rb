require "test_helper"

class UserPasskeyTest < ActiveSupport::TestCase
  test "can create with valid attributes" do
    user = users(:one)
    user_passkey = UserPasskey.new(id: SecureRandom.alphanumeric(24), user: user, public_key: "public_key", sign_count: 0)
    assert_nothing_raised { user_passkey.save! }
  end

  test "should be invalid wihtout id" do
    user = users(:one)
    user_passkey = UserPasskey.new(user: user, public_key: "public_key", sign_count: 0)
    error = assert_raises { user_passkey.save! }
    assert_equal ActiveRecord::NotNullViolation, error.class
  end
end
