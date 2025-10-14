require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
  end

  test "should be valid with valid email addresses" do
    invitation = Invitation.new(company: @company, email_address: "test@example.com", inviter_email_address: "inviter@example.com")
    assert invitation.valid?
  end

  # email_address validations
  test "should be invalid without email_address" do
    invitation = Invitation.new(company: @company, inviter_email_address: "inviter@example.com")
    assert_not invitation.valid?
    assert_includes invitation.errors.full_messages, "宛先メールアドレスを入力してください"
  end

  test "should be invalid with too long email_address" do
    invitation = Invitation.new(company: @company, email_address: "#{"a" * 244}@example.com", inviter_email_address: "inviter@example.com")
    assert_not invitation.valid?
    assert_includes invitation.errors.full_messages, "宛先メールアドレスは254文字以内で入力してください"
  end

  test "should be invalid with invalid email_address format" do
    invitation = Invitation.new(company: @company, email_address: "invalid", inviter_email_address: "inviter@example.com")
    assert_not invitation.valid?
    assert_includes invitation.errors.full_messages, "宛先メールアドレスの形式が正しくありません"
  end

  test "should be invalid with duplicate email_address and company_id" do
    Invitation.create!(company: @company, email_address: "test@example.com", inviter_email_address: "inviter@example.com")
    Invitation.create!(company: companies(:company_two), email_address: "test@example.com", inviter_email_address: "inviter@example.com")

    invitation = Invitation.new(company: @company, email_address: "test@example.com", inviter_email_address: "inviter@example.com")
    assert_not invitation.valid?
    assert_includes invitation.errors.full_messages, "宛先メールアドレスは招待済みです"
  end

  # inviter_email_address validations
  test "should be invalid without inviter_email_address" do
    invitation = Invitation.new(company: @company, email_address: "test@example.com")
    assert_not invitation.valid?
    assert_includes invitation.errors.full_messages, "招待者のメールアドレスを入力してください"
  end

  test "should be invalid with too long inviter_email_address" do
    invitation = Invitation.new(company: @company, email_address: "test@example.com", inviter_email_address: "#{"a" * 244}@example.com")
    assert_not invitation.valid?
    assert_includes invitation.errors.full_messages, "招待者のメールアドレスは254文字以内で入力してください"
  end

  test "should be invalid with invalid inviter_email_address format" do
    invitation = Invitation.new(company: @company, email_address: "test@example.com", inviter_email_address: "invalid")
    assert_not invitation.valid?
    assert_includes invitation.errors.full_messages, "招待者のメールアドレスの形式が正しくありません"
  end
end
