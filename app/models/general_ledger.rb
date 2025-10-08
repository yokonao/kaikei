class GeneralLedger
  class AccountTable
    Line = Data.define(:entry_id, :entry_date, :opponent_account_name, :amount)
    Balance = Data.define(:side, :amount)

    attr_reader :account, :debit_lines, :credit_lines

    def initialize(account)
      @account = account
      @debit_lines = []
      @credit_lines = []
    end

    def add_line(side:, entry_id:, entry_date:, opponent_account_name:, amount:)
      case side
      when "debit"
        @debit_lines << Line.new(entry_id: entry_id, entry_date: entry_date, opponent_account_name: opponent_account_name, amount: amount)
      when "credit"
        @credit_lines << Line.new(entry_id: entry_id, entry_date: entry_date, opponent_account_name: opponent_account_name, amount: amount)
      end
    end

    def balance
      total = @debit_lines.sum(&:amount) - @credit_lines.sum(&:amount)
      if total > 0
        Balance.new(side: "debit", amount: total)
      elsif total < 0
        Balance.new(side: "credit", amount: -total)
      else
        Balance.new(side: "none", amount: 0)
      end
    end
  end

  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :company
  attribute :start_date, :date
  attribute :end_date, :date

  attr_reader :account_tables

  def load!
    all_entries = @company.journal_entries.includes(journal_entry_lines: [ :account ]).where(entry_date: start_date..end_date).order(:entry_date, :id)
    balance_forwards = BalanceForward.includes(:account).where(company_id: @company.id).where(closing_date: start_date.yesterday..end_date).order(:closing_date, :id)

    # 日付ベースでソート、日付が同じなら残高繰越が後ろになる
    # e.g. 期末仕訳（3/31） → 残高繰越（3/31） → 期首仕訳（4/1）
    combined_entries = (all_entries + balance_forwards).sort_by do |entry|
      if entry.is_a?(BalanceForward)
        [ entry.closing_date, 1, entry.id ]
      else
        [ entry.entry_date, 0, entry.id ]
      end
    end

    @account_tables = {}
    combined_entries.each do |entry|
      if entry.is_a?(BalanceForward)
        if entry.closing_date >= start_date
          _add_line(account: entry.account, side: entry.side, entry_id: nil, entry_date: entry.closing_date, opponent_account_name: "次期繰越", amount: entry.amount)
        end
        if entry.closing_date.tomorrow <= end_date
          _add_line(account: entry.account, side: entry.opposite_side, entry_id: nil, entry_date: entry.closing_date.tomorrow, opponent_account_name: "前期繰越", amount: entry.amount)
        end
      elsif entry.is_a?(JournalEntry)
        debit_lines, credit_lines = entry.split_lines

        debit_lines.each do |line|
          _add_line(account: line.account, side: "debit", entry_id: entry.id, entry_date: entry.entry_date, opponent_account_name: _opponent_account_name(credit_lines), amount: line.amount)
        end
        credit_lines.each do |line|
          _add_line(account: line.account, side: "credit", entry_id: entry.id, entry_date: entry.entry_date, opponent_account_name: _opponent_account_name(debit_lines), amount: line.amount)
        end
      end
    end

    nil
  end

  private

  def _add_line(account:, side:, entry_id:, entry_date:, opponent_account_name:, amount:)
    @account_tables[account.name] ||= AccountTable.new(account)
    @account_tables[account.name].add_line(side: side, entry_id: entry_id, entry_date: entry_date, opponent_account_name: opponent_account_name, amount: amount)
  end

  def _opponent_account_name(lines)
    if lines.length == 1
      lines.first.account_name
    else
      "諸口"
    end
  end
end
