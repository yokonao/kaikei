require "test_helper"

class User::IncinerationTest < ActiveSupport::TestCase
  test "#run" do
    # Setup
    user = User.create!(email_address: "test-for-incineration@example.com")
    company = companies(:company_one)
    Session.create!(user: user)
    user.create_otp!
    user.user_passkeys.create!(
      id: "test_external_id_#{SecureRandom.uuid}",
      public_key: "test_public_key",
      sign_count: 0
    )

    # All models related to the user should be deleted
    Rails.application.eager_load!
    models_to_delete = ApplicationRecord.descendants.
                                         reject(&:abstract_class?).
                                         reject { |model| model == Membership }. # 事業所に所属しているユーザーは削除不可能という仕様があるのでここでは除外
                                         select { |model| model.column_names.include?("user_id") }
    assert_not_empty models_to_delete

    # Pre-assertions
    assert user.persisted?
    models_to_delete.each { |model| assert_not_empty model.where(user_id: user.id).to_a, "#{model} should not be empty" }

    # Action
    incineration = User::Incineration.new(user)
    incineration.run

    # Post-assertions
    assert user.destroyed?
    models_to_delete.each { |model| assert_empty model.where(user_id: user.id).to_a, "#{model} should be empty" }
  end

  test "should raise error when you try to delete a user who belongs to a company" do
    user = User.create!(email_address: "test-for-incineration@example.com")
    company = companies(:company_one)
    Membership.create!(user: user, company: company)

    incineration = User::Incineration.new(user)

    e = assert_raises(ActiveModel::ValidationError) do
      incineration.run
    end
    assert_includes e.message, "事業所に所属しているユーザーを削除することはできません"
  end
end
