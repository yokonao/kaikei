require "test_helper"

class ProfitAndLossTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
  end

  def create_journal_entries(company)
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 9, 1), summary: "9月の売上",
      journal_entry_lines_attributes: [
        { account: accounts(:sales), side: :credit, amount: 10000 },
        { account: accounts(:cash), side: :debit, amount: 10000 }
      ]
    )
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 9, 20), summary: "9月の売上2",
      journal_entry_lines_attributes: [
        { account: accounts(:sales), side: :credit, amount: 5000 },
        { account: accounts(:cash), side: :debit, amount: 5000 }
      ]
    )
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 9, 15), summary: "9月の仕入",
      journal_entry_lines_attributes: [
        { account: accounts(:cogs), side: :debit, amount: 3000 },
        { account: accounts(:cash), side: :credit, amount: 3000 }
      ]
    )
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 9, 25), summary: "9月の給与",
      journal_entry_lines_attributes: [
        { account: accounts(:salaries), side: :debit, amount: 1000 },
        { account: accounts(:cash), side: :credit, amount: 1000 }
      ]
    )
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 9, 25), summary: "9月の受取手数料",
      journal_entry_lines_attributes: [
        { account: accounts(:cash), side: :debit, amount: 1500 },
        { account: accounts(:commision), side: :credit, amount: 1500 }
      ]
    )

    # 収益 → 損益の振替仕訳
    JournalEntry.create!(
      company: company, entry_date: Date.new(2026, 3, 31), summary: "決算振替仕訳（収益 → 損益）",
      journal_entry_lines_attributes: [
        { account: accounts(:sales), side: :debit, amount: 15000 },
        { account: accounts(:commision), side: :debit, amount: 1500 },
        { account: accounts(:profit_and_loss), side: :credit, amount: 16500 }
      ]
    )

    # 費用 → 損益の振替仕訳
    JournalEntry.create!(
      company: company, entry_date: Date.new(2026, 3, 31), summary: "決算振替仕訳（費用 → 損益）",
      journal_entry_lines_attributes: [
        { account: accounts(:cogs), side: :credit, amount: 3000 },
        { account: accounts(:salaries), side: :credit, amount: 1000 },
        { account: accounts(:profit_and_loss), side: :debit, amount: 4000 }
      ]
    )
  end

  test "#load! calculates revenue and expense lines correctly" do
    create_journal_entries(@company)

    pl = ProfitAndLoss.new(company: @company, start_date: Date.new(2025, 4, 1), end_date: Date.new(2026, 3, 31))
    pl.load!

    assert_equal 2, pl.revenue_lines.size
    assert_equal 0, pl.total_revenue
    sales_line = pl.revenue_lines.find { |line| line.name == "売上高" }
    assert_equal 0, sales_line.amount

    assert_equal 2, pl.expense_lines.size
    assert_equal 0, pl.total_expenses
    cogs_line = pl.expense_lines.find { |line| line.name == "仕入高" }
    assert_equal 0, cogs_line.amount

    assert_equal 0, pl.net_income

    pl = ProfitAndLoss.new(company: @company, start_date: Date.new(2025, 4, 1), end_date: Date.new(2026, 3, 31), exclude_closing_entry: true)
    pl.load!

    assert_equal 2, pl.revenue_lines.size
    assert_equal 16500, pl.total_revenue
    sales_line = pl.revenue_lines.find { |line| line.name == "売上高" }
    assert_equal 15000, sales_line.amount

    assert_equal 2, pl.expense_lines.size
    assert_equal 4000, pl.total_expenses
    cogs_line = pl.expense_lines.find { |line| line.name == "仕入高" }
    assert_equal 3000, cogs_line.amount

    assert_equal 12500, pl.net_income
  end

  test "#load! calculates revenue and expense lines correctly with shorter period" do
    create_journal_entries(@company)

    pl = ProfitAndLoss.new(company: @company, start_date: Date.new(2025, 9, 1), end_date: Date.new(2025, 9, 30))
    pl.load!

    assert_equal 2, pl.revenue_lines.size
    assert_equal 16500, pl.total_revenue
    sales_line = pl.revenue_lines.find { |line| line.name == "売上高" }
    assert_equal 15000, sales_line.amount

    assert_equal 2, pl.expense_lines.size
    assert_equal 4000, pl.total_expenses
    cogs_line = pl.expense_lines.find { |line| line.name == "仕入高" }
    assert_equal 3000, cogs_line.amount

    assert_equal 12500, pl.net_income
  end
end
