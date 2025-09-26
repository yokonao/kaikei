require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    company = Company.new(name: "テスト会社")
    assert_nothing_raised { company.validate! }
  end

  test "should be invalid wihtout name" do
    company = Company.new
    assert_not company.valid?
    assert_includes company.errors.full_messages, "事業所名を入力してください"
  end
end
