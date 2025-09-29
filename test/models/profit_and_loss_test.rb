require "test_helper"

class ProfitAndLossTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
    @sales = accounts(:sales)
    @cogs = accounts(:cogs)
    @cash = accounts(:cash)
    @salaries = accounts(:salaries)
    @commision = accounts(:commision)

    # Create journal entries
    @sept_entry = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 9, 1), summary: "9月の売上",
      journal_entry_lines_attributes: [
        { account: @sales, side: :credit, amount: 10000 },
        { account: @cash, side: :debit, amount: 10000 }
      ]
    )
    @sept_entry_2 = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 9, 20), summary: "9月の売上2",
      journal_entry_lines_attributes: [
        { account: @sales, side: :credit, amount: 5000 },
        { account: @cash, side: :debit, amount: 5000 }
      ]
    )
    @sept_entry_3 = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 9, 15), summary: "9月の仕入",
      journal_entry_lines_attributes: [
        { account: @cogs, side: :debit, amount: 3000 },
        { account: @cash, side: :credit, amount: 3000 }
      ]
    )
    @sept_entry_4 = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 9, 25), summary: "9月の給与",
      journal_entry_lines_attributes: [
        { account: @salaries, side: :debit, amount: 1000 },
        { account: @cash, side: :credit, amount: 1000 }
      ]
    )
    @sept_entry_5 = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 9, 25), summary: "9月の受取手数料",
      journal_entry_lines_attributes: [
        { account: @cash, side: :debit, amount: 1500 },
        { account: @commision, side: :credit, amount: 1500 }
      ]
    )
    @oct_entry = JournalEntry.create!(
      company: @company, entry_date: Date.new(2025, 10, 1), summary: "10月の売上",
      journal_entry_lines_attributes: [
        { account: @sales, side: :credit, amount: 20000 },
        { account: @cash, side: :debit, amount: 20000 }
      ]
    )
  end

  test "should raise ArgumentError for invalid date" do
    assert_raises(ArgumentError) { ProfitAndLoss.new(@company, "invalid", Date.today) }
    assert_raises(ArgumentError) { ProfitAndLoss.new(@company, Date.today, "invalid") }
  end

  test "#load! calculates revenue and expense lines correctly for a given period" do
    start_date = Date.new(2025, 9, 1)
    end_date = Date.new(2025, 9, 30)
    pl = ProfitAndLoss.new(@company, start_date, end_date)
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
