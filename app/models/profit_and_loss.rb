class ProfitAndLoss
  Line = Data.define(:name, :amount)

  attr_reader :revenue_lines, :expense_lines

  def initialize(start_date, end_date)
    raise ArgumentError, "start_date must be a Date" unless start_date.is_a?(Date)
    raise ArgumentError, "end_date must be a Date" unless end_date.is_a?(Date)
    @start_date = start_date
    @end_date = end_date
    @revenue_lines = []
    @expense_lines = []
  end

  def load!
    pl_lines = JournalEntryLine.joins(:journal_entry).
                                includes(:account).
                                where("journal_entry.entry_date": @start_date..@end_date).
                                where("account.category": [ :revenue, :expense ])
    @revenue_lines = pl_lines.
                          filter { |line| line.account.revenue? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @expense_lines = pl_lines.
                          filter { |line| line.account.expense? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "debit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    nil
  end
end
