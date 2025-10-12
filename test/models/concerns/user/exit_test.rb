require "test_helper"

class User::ExitTest < ActiveSupport::TestCase
  test "#run" do
    # Setup
    user = users(:one)
    company1 = companies(:company_one)
    company2 = companies(:company_two)

    Membership.create!(user: user, company: company1)
    Membership.create!(user: user, company: company2)


    # 事業所1 からの脱退ができることをチェック
    assert_equal 2, user.companies.count
    assert user.companies.include?(company1)
    assert user.companies.include?(company2)

    exit = User::Exit.new(user, company1)
    exit.run

    assert_equal 1, user.companies.count
    assert_not user.companies.include?(company1)
    assert user.companies.include?(company2)
  end
end
