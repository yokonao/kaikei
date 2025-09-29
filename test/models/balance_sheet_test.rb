require "test_helper"

class BalanceSheetTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
    @cash = accounts(:cash)
    @accounts_payable = accounts(:payable)
    @capital_stock = accounts(:capital_stock)
    @sales = accounts(:sales)
    @cogs = accounts(:cogs)

    # Create journal entries
    @entry1 = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 4, 1), summary: "期首残高",
      journal_entry_lines_attributes: [
        { account: @cash, side: :debit, amount: 10000 },
        { account: @capital_stock, side: :credit, amount: 10000 }
      ]
    )

    @entry2 = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 5, 15), summary: "売上",
      journal_entry_lines_attributes: [
        { account: @cash, side: :debit, amount: 5000 },
        { account: @sales, side: :credit, amount: 5000 }
      ]
    )

    @entry3 = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 6, 20), summary: "仕入",
      journal_entry_lines_attributes: [
        { account: @cogs, side: :debit, amount: 3000 },
        { account: @accounts_payable, side: :credit, amount: 3000 }
      ]
    )
  end

  test "should raise ArgumentError for invalid date" do
    assert_raises(ArgumentError) { BalanceSheet.new(@company, "invalid") }
  end

  test "#load! calculates asset, liability, and equity lines correctly for a given date" do
    start_date = Date.new(2025, 4, 1)
    end_date = Date.new(2025, 6, 30)
    bs = BalanceSheet.new(@company, start_date, end_date)
    bs.load!

    assert_equal 1, bs.asset_lines.size
    assert_equal "現金", bs.asset_lines.first.name
    assert_equal 15000, bs.asset_lines.first.amount
    assert_equal 15000, bs.total_assets

    assert_equal 1, bs.liability_lines.size
    assert_equal "買掛金", bs.liability_lines.first.name
    assert_equal 3000, bs.liability_lines.first.amount
    assert_equal 3000, bs.total_liabilities

    assert_equal 2, bs.equity_lines.size # 資本金 + 当期純利益
    capital_line = bs.equity_lines.find { |line| line.name == "資本金" }
    net_income_line = bs.equity_lines.find { |line| line.name == "当期純利益" }
    assert_equal 10000, capital_line.amount
    assert_equal 2000, net_income_line.amount # 5000(売上) - 3000(仕入)
    assert_equal 12000, bs.total_equity

    assert_equal bs.total_assets, bs.total_liabilities + bs.total_equity
  end
end
