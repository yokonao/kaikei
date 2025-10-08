require "test_helper"

class GeneralLedgerTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
  end

  def create_journal_entries(company)
    # 4/1 現金 10000 / 資本金 10000
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 4, 1), summary: "期首残高",
      journal_entry_lines_attributes: [
        { account: accounts(:cash), side: :debit, amount: 10000 },
        { account: accounts(:capital_stock), side: :credit, amount: 10000 }
      ]
    )
    # 5/15 現金 5000 / 売上 5000
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 5, 15), summary: "売上",
      journal_entry_lines_attributes: [
        { account: accounts(:cash), side: :debit, amount: 5000 },
        { account: accounts(:sales), side: :credit, amount: 5000 }
      ]
    )
    # 6/20 仕入 3000 / 買掛金 3000
    JournalEntry.create!(
      company: company, entry_date: Date.new(2025, 6, 20), summary: "仕入",
      journal_entry_lines_attributes: [
        { account: accounts(:cogs), side: :debit, amount: 3000 },
        { account: accounts(:payable), side: :credit, amount: 3000 }
      ]
    )
  end

  test "#load! creates account tables correctly from journal entries" do
    create_journal_entries(@company)

    gl = GeneralLedger.new(company: @company, start_date: Date.new(2025, 4, 1), end_date: Date.new(2026, 3, 31))
    gl.load!

    assert_equal 5, gl.account_tables.size
    assert_includes gl.account_tables.keys, "現金"
    assert_includes gl.account_tables.keys, "資本金"
    assert_includes gl.account_tables.keys, "売上高"
    assert_includes gl.account_tables.keys, "仕入高"
    assert_includes gl.account_tables.keys, "買掛金"

    # 現金: 借方 15000
    cash_table = gl.account_tables["現金"]
    assert_equal "現金", cash_table.account.name
    assert_equal 2, cash_table.debit_lines.size
    assert_equal 0, cash_table.credit_lines.size
    assert_equal 15000, cash_table.debit_lines.sum(&:amount)
    assert_equal "debit", cash_table.balance.side
    assert_equal 15000, cash_table.balance.amount
    assert_equal "資本金", cash_table.debit_lines.first.opponent_account_name
    assert_equal "売上高", cash_table.debit_lines.second.opponent_account_name

    # 資本金: 貸方 10000
    capital_table = gl.account_tables["資本金"]
    assert_equal "credit", capital_table.balance.side
    assert_equal 10000, capital_table.balance.amount

    # 売上高: 貸方 5000
    sales_table = gl.account_tables["売上高"]
    assert_equal "credit", sales_table.balance.side
    assert_equal 5000, sales_table.balance.amount

    # 仕入高: 借方 3000
    cogs_table = gl.account_tables["仕入高"]
    assert_equal "debit", cogs_table.balance.side
    assert_equal 3000, cogs_table.balance.amount

    # 買掛金: 貸方 3000
    payable_table = gl.account_tables["買掛金"]
    assert_equal "credit", payable_table.balance.side
    assert_equal 3000, payable_table.balance.amount
  end

  test "#load! handles balance forwards correctly" do
    # --- GIVEN ---
    # 1. 前年度 (FY2024) の決算で残高が繰り越されている
    #    - 現金: 借方残高 2000円 -> 繰越仕訳で貸方へ (side: credit)
    #    - 繰越利益剰余金: 貸方残高 2000円 -> 繰越仕訳で借方へ (side: debit)
    fc = @company.financial_closings.create!(start_date: Date.new(2024, 4, 1), end_date: Date.new(2025, 3, 31), phase: :done)
    BalanceForward.create!(company: @company, financial_closing: fc, closing_date: fc.end_date, account: accounts(:cash), amount: 2000, side: :credit)
    BalanceForward.create!(company: @company, financial_closing: fc, closing_date: fc.end_date, account: accounts(:retained_earnings), amount: 2000, side: :debit)

    # 2. 当年度 (FY2025) の仕訳
    create_journal_entries(@company)

    # --- WHEN ---
    # FY2025 の総勘定元帳をロードする
    gl = GeneralLedger.new(company: @company, start_date: Date.new(2025, 4, 1), end_date: Date.new(2026, 3, 31))
    gl.load!

    # --- THEN ---
    # 現金: 前期繰越(借方) 2000 + 当期仕訳(借方) 15000 = 借方残高 17000
    cash_table = gl.account_tables["現金"]
    assert_equal 3, cash_table.debit_lines.size # 2 from entries + 1 from balance forward
    assert_equal 0, cash_table.credit_lines.size
    bf_line = cash_table.debit_lines.find { |l| l.opponent_account_name == "前期繰越" }
    assert_not_nil bf_line
    assert_equal Date.new(2025, 4, 1), bf_line.entry_date
    assert_equal 2000, bf_line.amount
    assert_equal "debit", cash_table.balance.side
    assert_equal 17000, cash_table.balance.amount

    # 繰越利益剰余金: 前期繰越(貸方) 2000 = 貸方残高 2000
    re_table = gl.account_tables["繰越利益剰余金"]
    assert_equal 0, re_table.debit_lines.size
    assert_equal 1, re_table.credit_lines.size
    bf_line_re = re_table.credit_lines.find { |l| l.opponent_account_name == "前期繰越" }
    assert_not_nil bf_line_re
    assert_equal Date.new(2025, 4, 1), bf_line_re.entry_date
    assert_equal 2000, bf_line_re.amount
    assert_equal "credit", re_table.balance.side
    assert_equal 2000, re_table.balance.amount
  end

  test "#load! handles closing entries within the period" do
    # --- GIVEN ---
    # 1. 当年度 (FY2025) の仕訳
    create_journal_entries(@company) # 現金: 借方残高 15000, 買掛金: 貸方残高 3000

    # 2. FY2025 の決算
    fc = @company.financial_closings.create!(start_date: Date.new(2025, 4, 1), end_date: Date.new(2026, 3, 31), phase: :done)
    #    - 現金: 借方残高 15000 -> 繰越仕訳で貸方へ (side: credit)
    BalanceForward.create!(company: @company, financial_closing: fc, closing_date: fc.end_date, account: accounts(:cash), amount: 15000, side: :credit)
    #    - 買掛金: 貸方残高 3000 -> 繰越仕訳で借方へ (side: debit)
    BalanceForward.create!(company: @company, financial_closing: fc, closing_date: fc.end_date, account: accounts(:payable), amount: 3000, side: :debit)

    # --- WHEN ---
    # 決算日をまたぐ期間の総勘定元帳をロードする
    gl = GeneralLedger.new(company: @company, start_date: Date.new(2026, 3, 1), end_date: Date.new(2026, 4, 30))
    gl.load!

    # --- THEN ---
    # 現金: 3/31に次期繰越（貸方）、4/1に前期繰越（借方）が表示される
    cash_table = gl.account_tables["現金"]
    closing_line = cash_table.credit_lines.find { |l| l.opponent_account_name == "次期繰越" }
    assert_not_nil closing_line
    assert_equal Date.new(2026, 3, 31), closing_line.entry_date
    assert_equal 15000, closing_line.amount

    opening_line = cash_table.debit_lines.find { |l| l.opponent_account_name == "前期繰越" }
    assert_not_nil opening_line
    assert_equal Date.new(2026, 4, 1), opening_line.entry_date
    assert_equal 15000, opening_line.amount

    # 買掛金: 3/31に次期繰越（借方）、4/1に前期繰越（貸方）が表示される
    payable_table = gl.account_tables["買掛金"]
    closing_line_p = payable_table.debit_lines.find { |l| l.opponent_account_name == "次期繰越" }
    assert_not_nil closing_line_p
    assert_equal Date.new(2026, 3, 31), closing_line_p.entry_date
    assert_equal 3000, closing_line_p.amount

    opening_line_p = payable_table.credit_lines.find { |l| l.opponent_account_name == "前期繰越" }
    assert_not_nil opening_line_p
    assert_equal Date.new(2026, 4, 1), opening_line_p.entry_date
    assert_equal 3000, opening_line_p.amount
  end
end
