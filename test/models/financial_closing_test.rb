require "test_helper"

class FinancialClosingTest < ActiveSupport::TestCase
  setup do
    @company = companies(:company_one)
  end

  test "should be valid with valid attributes" do
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2024, 4, 1),
      end_date: Date.new(2025, 3, 31),
      phase: :adjusting
    )
    assert_nothing_raised { fc.validate! }
  end

  test "should be invalid without company" do
    fc = FinancialClosing.new(
      start_date: Date.new(2024, 4, 1),
      end_date: Date.new(2025, 3, 31),
      phase: :closing
    )
    assert_not fc.valid?
    assert_includes fc.errors.full_messages, "事業所を指定してください"
  end

  test "should be invalid without start_date" do
    fc = FinancialClosing.new(
      company: @company,
      end_date: Date.new(2025, 3, 31),
      phase: :closing
    )
    assert_not fc.valid?
    assert_includes fc.errors.full_messages, "決算の開始日を入力してください"
  end

  test "should be invalid without end_date" do
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2024, 4, 1),
      phase: :done
    )
    assert_not fc.valid?
    assert_includes fc.errors.full_messages, "決算の終了日を入力してください"
  end

  test "should be invalid without phase" do
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2024, 4, 1),
      end_date: Date.new(2025, 3, 31)
    )
    assert_not fc.valid?
    assert_includes fc.errors.full_messages, "フェーズを入力してください"
  end

  test "should be invalid with invalid date range" do
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2025, 3, 31),
      end_date: Date.new(2025, 3, 31),
      phase: :adjusting
    )
    assert_not fc.valid?
    assert_includes fc.errors.full_messages, "決算の終了日は開始日より後の日付を指定してください"
  end

  test "should be invalid with too long date range" do
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2025, 4, 1),
      end_date: Date.new(2026, 10, 1),
      phase: :adjusting
    )
    assert_not fc.valid?
    assert_includes fc.errors.full_messages, "決算期間は1年半以内にしなければいけません"
  end

  test "should be valid with 1.5 year date range" do
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2025, 4, 1),
      end_date: Date.new(2026, 9, 30),
      phase: :adjusting
    )
    assert_nothing_raised { fc.validate! }
  end

  test "should be valid with previous closing and correct start_date" do
    FinancialClosing.create!(
      company: @company,
      start_date: Date.new(2023, 4, 1),
      end_date: Date.new(2024, 3, 31),
      phase: :adjusting
    )
    FinancialClosing.create!(
      company: @company,
      start_date: Date.new(2024, 4, 1),
      end_date: Date.new(2025, 3, 31),
      phase: :adjusting
    )
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2025, 4, 1),
      end_date: Date.new(2026, 3, 30),
      phase: :adjusting
    )
    assert_nothing_raised { fc.validate! }
  end

  test "should be valid with previous closing and wrong start_date" do
    FinancialClosing.create!(
      company: @company,
      start_date: Date.new(2023, 4, 1),
      end_date: Date.new(2024, 3, 31),
      phase: :adjusting
    )
    FinancialClosing.create!(
      company: @company,
      start_date: Date.new(2024, 4, 1),
      end_date: Date.new(2025, 3, 31),
      phase: :adjusting
    )
    fc = FinancialClosing.new(
      company: @company,
      start_date: Date.new(2025, 9, 1),
      end_date: Date.new(2026, 8, 30),
      phase: :adjusting
    )
    assert_not fc.valid?
    assert_includes fc.errors.full_messages, "決算の開始日は前回決算の終了日の翌日にしてください"
  end
end
