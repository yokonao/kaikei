class ProfitAndLoss
  Line = Data.define(:name, :amount)

  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :company
  attribute :start_date, :date
  attribute :end_date, :date

  attr_reader :revenue_lines, :expense_lines

  def load!
    pl_lines = JournalEntryLine.joins(:journal_entry).
                                includes(:account).
                                where("journal_entry.company_id": company.id).
                                where("journal_entry.entry_date": start_date..end_date).
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

  def total_revenue
    @revenue_lines.sum { |line| line.amount }
  end

  def total_expenses
    @expense_lines.sum { |line| line.amount }
  end

  def net_income
    total_revenue - total_expenses
  end
end
