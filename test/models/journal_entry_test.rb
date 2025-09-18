require "test_helper"

class JournalEntryTest < ActiveSupport::TestCase
  [
    { entry_date: Date.current, summary: "テスト仕訳" },
    { entry_date: Date.current.tomorrow, summary: "a" * 200 },
    { entry_date: Date.current.yesterday, summary: "" },
    { entry_date: Date.current - 30 }
  ].each do |tc|
    test "should be valid with valid attributes #{tc}" do
      journal_entry = JournalEntry.new(**tc)
      assert_nothing_raised { journal_entry.valid? }
    end
  end

  test "should be valid with balanced lines" do
    cash_account = accounts(:cash)
    capital_stock_account = accounts(:capital_stock)
    journal_entry = JournalEntry.new(
      entry_date: Date.today,
      summary: "貸借が一致していない仕訳",
      journal_entry_lines_attributes: [
        { amount: 1000, side: :debit, account: cash_account },
        { amount: 1000, side: :credit, account: capital_stock_account }
      ]
    )
    assert_nothing_raised { journal_entry.valid? }
  end

  test "should save valid journal entry" do
    journal_entry = JournalEntry.new(entry_date: Date.today, summary: "保存テスト")
    assert journal_entry.save
    assert_not_nil journal_entry.id
  end

  test "should require entry_date" do
    journal_entry = JournalEntry.new(summary: "テスト仕訳")
    assert_not journal_entry.valid?
    assert_includes journal_entry.errors.full_messages, "仕訳日を入力してください"
  end

  test "should enforce maximum length of summary" do
    journal_entry = JournalEntry.new(entry_date: Date.today, summary: "a" * 201)
    assert_not journal_entry.valid?
    assert_includes journal_entry.errors.full_messages, "摘要は200文字以内で入力してください"
  end

  test "should enforce balanced" do
    cash_account = accounts(:cash)
    capital_stock_account = accounts(:capital_stock)
    journal_entry = JournalEntry.new(
      entry_date: Date.today,
      summary: "貸借が一致していない仕訳",
      journal_entry_lines_attributes: [
        { amount: 1000, side: :debit, account: cash_account },
        { amount: 2000, side: :credit, account: capital_stock_account }
      ]
    )
    assert_not journal_entry.valid?
    assert_includes journal_entry.errors.full_messages, "借方と貸方の金額が一致していません"
  end
end
