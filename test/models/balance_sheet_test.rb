require "test_helper"

class BalanceSheetTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
  end

  def create_journal_entries(company)
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 4, 1), summary: "期首残高",
      journal_entry_lines_attributes: [
        { account: accounts(:cash), side: :debit, amount: 10000 },
        { account: accounts(:capital_stock), side: :credit, amount: 10000 }
      ]
    )
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 5, 15), summary: "売上",
      journal_entry_lines_attributes: [
        { account: accounts(:cash), side: :debit, amount: 5000 },
        { account: accounts(:sales), side: :credit, amount: 5000 }
      ]
    )
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 6, 20), summary: "仕入",
      journal_entry_lines_attributes: [
        { account: accounts(:cogs), side: :debit, amount: 3000 },
        { account: accounts(:payable), side: :credit, amount: 3000 }
      ]
    )

    # 収益 → 損益の振替仕訳
    JournalEntry.create!(
      company: company, entry_date: Date.new(2026, 3, 31), summary: "決算振替仕訳（収益 → 損益）",
      journal_entry_lines_attributes: [
        { account: accounts(:sales), side: :debit, amount: 5000 },
        { account: accounts(:profit_and_loss), side: :credit, amount: 5000 }
      ]
    )

    # 費用 → 損益の振替仕訳
    JournalEntry.create!(
      company: company, entry_date: Date.new(2026, 3, 31), summary: "決算振替仕訳（費用 → 損益）",
      journal_entry_lines_attributes: [
        { account: accounts(:cogs), side: :credit, amount: 3000 },
        { account: accounts(:profit_and_loss), side: :debit, amount: 3000 }
      ]
    )

    # 損益 → 繰越利益剰余金の振替仕訳
    JournalEntry.create!(
      company: company, entry_date: Date.new(2026, 3, 31), summary: "決算振替仕訳（損益 → 繰越利益剰余金)",
      journal_entry_lines_attributes: [
        { account: accounts(:profit_and_loss), side: :debit, amount: 2000 },
        { account: accounts(:retained_earnings), side: :credit, amount: 2000 }
      ]
    )
  end

  test "#load! calculates asset, liability, and equity lines correctly for a given date" do
    create_journal_entries(@company)

    bs = BalanceSheet.new(company: @company, start_date: Date.new(2025, 4, 1), end_date: Date.new(2026, 3, 31))
    bs.load!

    assert_equal 1, bs.asset_lines.size
    assert_equal "現金", bs.asset_lines.first.name
    assert_equal 15000, bs.asset_lines.first.amount
    assert_equal 15000, bs.total_assets

    assert_equal 1, bs.liability_lines.size
    assert_equal "買掛金", bs.liability_lines.first.name
    assert_equal 3000, bs.liability_lines.first.amount
    assert_equal 3000, bs.total_liabilities

    assert_equal 2, bs.equity_lines.size
    capital_line = bs.equity_lines.find { |line| line.name == "資本金" }
    assert_equal 10000, capital_line.amount
    retained_earnings_line = bs.equity_lines.find { |line| line.name == "繰越利益剰余金" }
    assert_equal 2000, retained_earnings_line.amount # 5000(売上) - 3000(仕入)
    assert_equal 12000, bs.total_equity

    assert_equal bs.total_assets, bs.total_liabilities + bs.total_equity
  end
end
