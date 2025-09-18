require "test_helper"

class JournalEntryLineTest < ActiveSupport::TestCase
  def setup
    @journal_entry = journal_entries(:valid_entry)
    @cash_account = accounts(:cash)
  end

  test "valid debit entry" do
    entry_line = JournalEntryLine.new(
      amount: 1000.0,
      side: :debit,
      journal_entry: @journal_entry,
      account: @cash_account
    )
    assert_nothing_raised { entry_line.validate! }
  end

  test "valid credit entry" do
    entry_line = JournalEntryLine.new(
      amount: 1000.0,
      side: :credit,
      journal_entry: @journal_entry,
      account: @cash_account
    )
    assert_nothing_raised { entry_line.validate! }
  end

  test "should be invalid with zero amount" do
    entry_line = JournalEntryLine.new(
      amount: 0,
      side: :credit,
      journal_entry: @journal_entry,
      account: @cash_account
    )
    assert_not entry_line.valid?
    assert_includes entry_line.errors.full_messages, "金額は0より大きい値にしてください"
  end

  test "should be invalid with negative amount" do
    entry_line = JournalEntryLine.new(
      amount: -10000,
      side: :credit,
      journal_entry: @journal_entry,
      account: @cash_account
    )
    assert_not entry_line.valid?
    assert_includes entry_line.errors.full_messages, "金額は0より大きい値にしてください"
  end

  test "should be invalid with amount exceeding maximum" do
    entry_line = JournalEntryLine.new(
      amount: 1_000_000_000_000,
      side: :credit,
      journal_entry: @journal_entry,
      account: @cash_account
    )
    assert_not entry_line.valid?
    assert_includes entry_line.errors.full_messages, "金額は999999999999以下の値にしてください"
  end

  test "should be invalid with invalid side" do
    entry_line = JournalEntryLine.new(
      amount: 1000,
      side: "unknown",
      journal_entry: @journal_entry,
      account: @cash_account
    )
    assert_not entry_line.valid?
    assert_includes entry_line.errors.full_messages, "借方・貸方は debit または credit で指定してください"
  end

  test "invalid without journal_entry" do
    entry_line = JournalEntryLine.new(
      amount: 1000.0,
      side: :debit,
      account: @cash_account
    )
    assert_not entry_line.valid?
    assert_includes entry_line.errors.full_messages, "仕訳を指定してください"
  end

  test "invalid without account" do
    entry_line = JournalEntryLine.new(
      amount: 1000.0,
      side: :debit,
      journal_entry: @journal_entry
    )
    assert_not entry_line.valid?
    assert_includes entry_line.errors.full_messages, "勘定科目を指定してください"
  end
end
