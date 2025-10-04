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
end
