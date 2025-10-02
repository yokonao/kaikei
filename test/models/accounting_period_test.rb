# frozen_string_literal: true

require 'test_helper'

class AccountingPeriodTest < ActiveSupport::TestCase
  test '.from_date' do
    # 基準日が開始月より前の場合
    period1 = AccountingPeriod.from_date(Date.new(2025, 1, 15), start_month: 4)
    assert_equal Date.new(2024, 4, 1), period1.start_date
    assert_equal Date.new(2025, 3, 31), period1.end_date

    # 基準日が開始月以降の場合
    period2 = AccountingPeriod.from_date(Date.new(2025, 6, 15), start_month: 4)
    assert_equal Date.new(2025, 4, 1), period2.start_date
    assert_equal Date.new(2026, 3, 31), period2.end_date

    # 別の開始月でのテスト
    period3 = AccountingPeriod.from_date(Date.new(2025, 8, 1), start_month: 10)
    assert_equal Date.new(2024, 10, 1), period3.start_date
    assert_equal Date.new(2025, 9, 30), period3.end_date

    # 基準日が開始月と同じ場合
    period4 = AccountingPeriod.from_date(Date.new(2025, 4, 1), start_month: 4)
    assert_equal Date.new(2025, 4, 1), period4.start_date
    assert_equal Date.new(2026, 3, 31), period4.end_date

    # 基準日が期末の日付の場合
    period5 = AccountingPeriod.from_date(Date.new(2025, 12, 31), start_month: 1)
    assert_equal Date.new(2025, 1, 1), period5.start_date
    assert_equal Date.new(2025, 12, 31), period5.end_date
  end
end
