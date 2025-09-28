class BalanceSheet
  Line = Data.define(:name, :amount)

  attr_reader :asset_lines, :liability_lines, :equity_lines

  def initialize(company, start_date, end_date)
    @company = company
    raise ArgumentError, "start_date must be a Date" unless start_date.is_a?(Date)
    raise ArgumentError, "end_date must be a Date" unless end_date.is_a?(Date)
    @start_date = start_date
    @end_date = end_date
    @asset_lines = []
    @liability_lines = []
    @equity_lines = []
  end

  def load!
    bs_lines = JournalEntryLine.joins(:journal_entry).
                                includes(:account).
                                where("journal_entry.company_id": @company.id).
                                where("journal_entry.entry_date": @start_date..@end_date).
                                where("account.category": [ :asset, :liability, :equity ])

    @asset_lines = bs_lines.
                          filter { |line| line.account.asset? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "debit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @liability_lines = bs_lines.
                          filter { |line| line.account.liability? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @equity_lines = bs_lines.
                          filter { |line| line.account.equity? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }

    # Add net income to equity
    pl = ProfitAndLoss.new(@company, @start_date, @end_date)
    pl.load!
    @equity_lines << Line.new(name: "当期純利益", amount: pl.net_income)

    nil
  end

  def total_assets
    @asset_lines.sum { |line| line.amount }
  end

  def total_liabilities
    @liability_lines.sum { |line| line.amount }
  end

  def total_equity
    @equity_lines.sum { |line| line.amount }
  end
end
