class BalanceSheet
  Line = Data.define(:name, :amount)

  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :company
  attribute :start_date, :date
  attribute :end_date, :date

  attr_reader :asset_lines, :total_assets, :liability_lines, :total_liabilities, :equity_lines, :total_equity

  def load!
    bs_lines = JournalEntryLine.joins(:journal_entry).
                                includes(:account).
                                where("journal_entry.company_id": company.id).
                                where("journal_entry.entry_date": start_date..end_date).
                                where("account.category": [ :asset, :liability, :equity ])

    @asset_lines = bs_lines.
                          filter { |line| line.account.asset? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "debit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @total_assets = @asset_lines.sum(&:amount)

    @liability_lines = bs_lines.
                          filter { |line| line.account.liability? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @total_liabilities = @liability_lines.sum(&:amount)

    @equity_lines = bs_lines.
                          filter { |line| line.account.equity? }.
                          group_by { |line| line.account_name }.
                          transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
                          map { |k, v| Line.new(name: k, amount: v) }
    @total_equity = @equity_lines.sum(&:amount)

    nil
  end
end
