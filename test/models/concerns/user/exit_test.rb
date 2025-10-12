require "test_helper"

class User::ExitTest < ActiveSupport::TestCase
  setup do
    @user1 = users(:one)
    @user2 = users(:two)
    @company1 = companies(:company_one)
    @company2 = companies(:company_two)
  end

  test "should raise an error when user does not belong to the company" do
    @company2.users << @user1

    user_exit = User::Exit.new(@user1, @company1)

    assert_not user_exit.valid?
    assert_includes user_exit.errors[:base], "ユーザーは事業所に所属していません"

    assert_raises(ActiveModel::ValidationError) do
      user_exit.run
    end
  end

  test "should raise an error when user is the last member of the company" do
    @company1.users << @user1

    user_exit = User::Exit.new(@user1, @company1)

    assert_not user_exit.valid?
    assert_includes user_exit.errors[:base], "事業所の最後のメンバーは脱退できません。代わりに事業所を削除してください"

    assert_raises(ActiveModel::ValidationError) do
      user_exit.run
    end
  end

  test "should remove membership when user is not the last member" do
    @company1.users << @user1
    @company1.users << @user2

    user_exit = User::Exit.new(@user1, @company1)

    assert user_exit.valid?

    assert_difference("Membership.count", -1) do
      user_exit.run
    end

    assert_not @company1.users.exists?(@user1.id)
    assert @company1.users.exists?(@user2.id)
  end
end
