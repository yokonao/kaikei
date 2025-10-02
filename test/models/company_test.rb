require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    company = Company.new(name: "テスト会社", fy_start_month_num: 4)
    assert_nothing_raised { company.validate! }
  end

  test "should be invalid wihtout name" do
    company = Company.new(fy_start_month_num: 4)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "事業所名を入力してください"
  end

  test "should be valid without fy_start_month_num" do
    company = Company.new(name: "テスト会社")
    assert company.valid?
    assert_equal 4, company.fy_start_month_num
  end

  test "should be invalid with zero fy_start_month_num" do
    company = Company.new(name: "テスト会社", fy_start_month_num: 0)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "会計年度の開始月は1月から12月のいずれかを指定してください"
  end

  test "should be invalid with negative fy_start_month_num" do
    company = Company.new(name: "テスト会社", fy_start_month_num: -1)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "会計年度の開始月は1月から12月のいずれかを指定してください"
  end

  test "should be invalid with too big fy_start_month_num" do
    company = Company.new(name: "テスト会社", fy_start_month_num: 13)
    assert_not company.valid?
    assert_includes company.errors.full_messages, "会計年度の開始月は1月から12月のいずれかを指定してください"
  end
end
