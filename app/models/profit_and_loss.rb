class ProfitAndLoss
  Line = Data.define(:name, :amount)

  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :company
  attribute :start_date, :date
  attribute :end_date, :date
  # 決算処理で生成される仕訳を除外するかどうか
  attribute :exclude_closing_entry, :boolean

  attr_reader :revenue_lines, :total_revenue, :expense_lines, :total_expenses

  def load!
    all_entries = @company.journal_entries.includes(journal_entry_lines: [ :account ]).where(entry_date: start_date..end_date)
    if exclude_closing_entry
      all_entries = all_entries.reject do |entry|
        entry.journal_entry_lines.any? { |line| line.account_name == "損益" }
      end
    end

    pl_lines = all_entries.flat_map do |entry|
      entry.journal_entry_lines.filter { |line| line.account.revenue? || line.account.expense? }
    end

    @revenue_lines = pl_lines.
                          filter { |line| line.account.revenue? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @total_revenue = @revenue_lines.sum(&:amount)

    @expense_lines = pl_lines.
                          filter { |line| line.account.expense? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "debit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @total_expenses = @expense_lines.sum(&:amount)

    nil
  end

  def net_income
    total_revenue - total_expenses
  end
end
