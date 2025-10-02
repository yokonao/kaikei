require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    company = Company.new(name: "テスト会社", accounting_period_start_month: 4)
    assert_nothing_raised { company.validate! }
  end

  test "should be invalid wihtout name" do
    company = Company.new(accounting_period_start_month: 4)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "事業所名を入力してください"
  end

  test "should be valid without accounting_period_start_month" do
    company = Company.new(name: "テスト会社")
    assert company.valid?
    assert_equal 4, company.accounting_period_start_month
  end

  test "should be invalid with zero accounting_period_start_month" do
    company = Company.new(name: "テスト会社", accounting_period_start_month: 0)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "会計年度の開始月は1月から12月のいずれかを指定してください"
  end

  test "should be invalid with negative accounting_period_start_month" do
    company = Company.new(name: "テスト会社", accounting_period_start_month: -1)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "会計年度の開始月は1月から12月のいずれかを指定してください"
  end

  test "should be invalid with too big accounting_period_start_month" do
    company = Company.new(name: "テスト会社", accounting_period_start_month: 13)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "会計年度の開始月は1月から12月のいずれかを指定してください"
  end
end
