require "test_helper"

class BalanceForwardTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
    @financial_closing = FinancialClosing.create!(
      company: @company,
      start_date: Date.new(2024, 4, 1),
      end_date: Date.new(2025, 3, 31),
      phase: :adjusting
    )
  end

  test "should be valid with valid attributes" do
    bf = BalanceForward.new(
      company: @company,
      financial_closing: @financial_closing,
      account: accounts(:cash),
      closing_date: Date.today,
      amount: 1000,
      side: "debit"
    )
    assert_nothing_raised { bf.validate! }
  end

  test "should be invalid without company" do
    bf = BalanceForward.new(
      financial_closing: @financial_closing,
      account: accounts(:cash),
      closing_date: Date.today,
      amount: 1000,
      side: "credit"
    )
    assert_not bf.valid?
    assert_includes bf.errors.full_messages, "事業所を指定してください"
  end

  test "should be invalid without financial_closing" do
    bf = BalanceForward.new(
      company: @company,
      account: accounts(:cash),
      closing_date: Date.today,
      amount: 1000,
      side: "debit"
    )
    assert_not bf.valid?
    assert_includes bf.errors.full_messages, "決算を指定してください"
  end

  test "should be invalid without account" do
    bf = BalanceForward.new(
      company: @company,
      financial_closing: @financial_closing,
      closing_date: Date.today,
      amount: 1000,
      side: "credit"
    )
    assert_not bf.valid?
    assert_includes bf.errors.full_messages, "勘定科目を指定してください"
  end

  test "should be invalid without closing_date" do
    bf = BalanceForward.new(
      company: @company,
      financial_closing: @financial_closing,
      account: accounts(:cash),
      amount: 1000,
      side: "debit"
    )
    assert_not bf.valid?
    assert_includes bf.errors.full_messages, "決算日を入力してください"
  end

  test "should be invalid without amount" do
    bf = BalanceForward.new(
      company: @company,
      financial_closing: @financial_closing,
      account: accounts(:cash),
      closing_date: Date.today,
      side: "credit"
    )
    assert_not bf.valid?
    assert_includes bf.errors.full_messages, "金額を入力してください"
  end

  test "should be invalid with unknown side" do
    e = assert_raises ArgumentError do
      BalanceForward.new(
        company: @company,
        financial_closing: @financial_closing,
        account: accounts(:cash),
        closing_date: Date.today,
        amount: 1000,
        side: "unknown"
      )
    end
    assert_equal "'unknown' is not a valid side", e.message
  end
end
