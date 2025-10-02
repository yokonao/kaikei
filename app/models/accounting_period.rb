class AccountingPeriod
  attr_accessor :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  # 指定された日付と開始月を基に適切な会計期間を生成します。
  # 生成される会計期間の幅は12ヶ月であり、必ず指定した日付を含みます。
  #
  # @param date [Date] 期間を決定するための基準となる日付。
  # @param start_month [Integer] 期間の開始月を示す1から12までの整数。
  # @return [Object] 期間の開始日と終了日を持つ会計期間インスタンス。
  #
  # @example
  #   from_date(Date.new(2025, 1, 15), start_month: 4)
  #   # => new(Date.new(2024, 4, 1), Date.new(2025, 3, 31))
  #   from_date(Date.new(2025, 6, 15), start_month: 4)
  #   # => new(Date.new(2025, 4, 1), Date.new(2026, 3, 31))
  #   from_date(Date.new(2025, 8, 1), start_month: 10)
  #   # => new(Date.new(2024, 10, 1), Date.new(2025, 9, 30))
  def self.from_date(date, start_month:)
    if date.month < start_month
      start_date = Date.new(date.year - 1, start_month, 1)
      end_date = Date.new(date.year, start_month, 1).days_ago(1)
    else
      start_date = Date.new(date.year, start_month, 1)
      end_date = Date.new(date.year + 1, start_month, 1).days_ago(1)
    end

    new(start_date, end_date)
  end
end
