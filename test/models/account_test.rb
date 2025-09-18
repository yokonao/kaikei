require "test_helper"

class AccountTest < ActiveSupport::TestCase
  [
    { name: "現金", category: :asset, is_standard: true },
    { name: "買掛金", category: :liability, is_standard: true },
    { name: "資本金", category: :equity, is_standard: true },
    { name: "売上高", category: :revenue, is_standard: true },
    { name: "仕入高", category: :expense, is_standard: true },
    { name: "  現金  ", category: :asset, is_standard: false },
    { name: "Cash", category: :asset, is_standard: false },
    { name: "売掛金・商品券", category: :asset, is_standard: false }
  ].each do |tc|
    test "should be valid with valid attributes #{tc}" do
      account = Account.new(**tc)
      assert account.valid?
    end
  end

  test "should require name" do
    account = Account.new(category: :asset, is_standard: true)
    assert_not account.valid?
    assert_includes account.errors.full_messages, "勘定科目名を入力してください"
  end

  test "should require category" do
    account = Account.new(name: "現金")
    assert_not account.valid?
    assert_includes account.errors.full_messages, "区分（資産・負債・資本・収益・費用）を指定してください"
  end

  test "should enforce maximum length of name" do
    account = Account.new(name: "a" * 51, category: :asset, is_standard: false)
    assert_not account.valid?
    assert_includes account.errors.full_messages, "勘定科目名は50文字以内で入力してください"
  end

  test "should enforce uniqueness of name" do
    Account.create!(name: "現金", category: :asset, is_standard: true)
    duplicate_account = Account.new(name: "現金", category: :liability, is_standard: true)
    assert_not duplicate_account.valid?
    assert_includes duplicate_account.errors.full_messages, "勘定科目名が重複しています"
  end

  test "should enforce is_standard is true or false" do
    account = Account.new(name: "現金", category: :asset, is_standard: nil)
    assert_not account.valid?
    assert_includes account.errors.full_messages, "デフォルト勘定科目かどうかは真偽値で指定してください"
  end

  test "should have asset category" do
    account = Account.new(name: "現金", category: :asset, is_standard: true)
    assert account.asset?
    assert_equal "asset", account.category
    assert_equal 1, Account.categories["asset"]
  end

  test "should have liability category" do
    account = Account.new(name: "買掛金", category: :liability, is_standard: true)
    assert account.liability?
    assert_equal "liability", account.category
    assert_equal 2, Account.categories["liability"]
  end

  test "should have equity category" do
    account = Account.new(name: "資本金", category: :equity, is_standard: true)
    assert account.equity?
    assert_equal "equity", account.category
    assert_equal 3, Account.categories["equity"]
  end

  test "should have revenue category" do
    account = Account.new(name: "売上高", category: :revenue, is_standard: true)
    assert account.revenue?
    assert_equal "revenue", account.category
    assert_equal 4, Account.categories["revenue"]
  end

  test "should have expense category" do
    account = Account.new(name: "仕入", category: :expense, is_standard: true)
    assert account.expense?
    assert_equal "expense", account.category
    assert_equal 5, Account.categories["expense"]
  end
end
