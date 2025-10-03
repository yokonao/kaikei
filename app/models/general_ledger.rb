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

    def add_debit_line(entry_id, entry_date, opponent_account_name, amount)
      @debit_lines << Line.new(entry_id: entry_id, entry_date: entry_date, opponent_account_name: opponent_account_name, amount: amount)
    end

    def add_credit_line(entry_id, entry_date, opponent_account_name, amount)
      @credit_lines << Line.new(entry_id: entry_id, entry_date: entry_date, opponent_account_name: opponent_account_name, amount: amount)
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
    all_entries = @company.journal_entries.includes(journal_entry_lines: [ :account ]).where(entry_date: @start_date..@end_date).order(:entry_date, :id)
    @account_tables = {}

    all_entries.each do |entry|
      debit_lines = entry.journal_entry_lines.filter { |line| line.side == "debit" }
      credit_lines = entry.journal_entry_lines.filter { |line| line.side == "credit" }

      debit_lines.each do |line|
        @account_tables[line.account_name] ||= AccountTable.new(line.account)
        @account_tables[line.account_name].add_debit_line(entry.id, entry.entry_date, credit_lines.length == 1 ? credit_lines.first.account_name : "諸口", line.amount)
      end

      credit_lines.each do |line|
        @account_tables[line.account_name] ||= AccountTable.new(line.account)
        @account_tables[line.account_name].add_credit_line(entry.id, entry.entry_date, debit_lines.length == 1 ? debit_lines.first.account_name : "諸口", line.amount)
      end
    end

    nil
  end
end
