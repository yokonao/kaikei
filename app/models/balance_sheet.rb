class BalanceSheet
  Line = Data.define(:name, :amount)

  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :company
  attribute :start_date, :date
  attribute :end_date, :date

  attr_reader :asset_lines, :total_assets, :liability_lines, :total_liabilities, :equity_lines, :total_equity

  def load!
    asset_balances, liability_balances, equity_balances = Hash.new(0), Hash.new(0), Hash.new(0)
    balance_forwards = BalanceForward.includes(:account).
                                      where(company_id: company.id).
                                      where(closing_date: start_date.yesterday)
    balance_forwards.each do |bf|
      case bf.account.category
      when "asset"
        asset_balances[bf.account_name] = bf.side == "credit" ? bf.amount : -bf.amount
      when "liability"
        liability_balances[bf.account_name] = bf.side == "debit" ? bf.amount : -bf.amount
      when "equity"
        equity_balances[bf.account_name] = bf.side == "debit" ? bf.amount : -bf.amount
      end
    end

    bs_lines = JournalEntryLine.joins(:journal_entry).
                                includes(:account).
                                where("journal_entry.company_id": company.id).
                                where("journal_entry.entry_date": start_date..end_date).
                                where("account.category": [ :asset, :liability, :equity ])

    bs_lines.filter { |line| line.account.asset? }.
             group_by { |line| line.account_name }.
             transform_values { |lines| lines.sum { |line| line.side == "debit" ? line.amount : -line.amount } }.
             each { |k, v| asset_balances[k] += v }
    @asset_lines = asset_balances.map { |k, v| Line.new(name: k, amount: v) }.reject { |line| line.amount.zero? }
    @asset_lines = @asset_lines.sort_by { |line| [ AccountOrder.account_order(line.name), line.name ] }
    @total_assets = @asset_lines.sum(&:amount)

    bs_lines.filter { |line| line.account.liability? }.
             group_by { |line| line.account_name }.
             transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
             each { |k, v| liability_balances[k] += v }
    @liability_lines = liability_balances.map { |k, v| Line.new(name: k, amount: v) }.reject { |line| line.amount.zero? }
    @liability_lines = @liability_lines.sort_by { |line| [ AccountOrder.account_order(line.name), line.name ] }
    @total_liabilities = @liability_lines.sum(&:amount)

    bs_lines.filter { |line| line.account.equity? }.
             group_by { |line| line.account_name }.
             transform_values { |lines| lines.sum { |line| line.side == "credit" ? line.amount : -line.amount } }.
             each { |k, v| equity_balances[k] += v }
    @equity_lines = equity_balances.map { |k, v| Line.new(name: k, amount: v) }.reject { |line| line.amount.zero? }
    @equity_lines = @equity_lines.sort_by { |line| [ AccountOrder.account_order(line.name), line.name ] }
    @total_equity = @equity_lines.sum(&:amount)

    nil
  end
end
