class ProfitAndLoss
  Line = Data.define(:name, :amount)

  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :company
  attribute :start_date, :date
  attribute :end_date, :date
  # 決算処理で生成される仕訳を除外するかどうか
  attribute :exclude_closing_entry, :boolean

  attr_reader :revenue_lines, :expense_lines

  def load!
    pl_lines = JournalEntryLine.includes(:journal_entry, :account).
                                where("journal_entry.company_id": company.id).
                                where("journal_entry.entry_date": start_date..end_date).
                                where("account.category": [ :revenue, :expense ])

    if exclude_closing_entry
      pl_lines = pl_lines.reject do |line|
        line.journal_entry.journal_entry_lines.any? { |line| line.account_name == "損益" }
      end
    end

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
