class GeneralLedger
  class AccountTable
    Line = Data.define(:entry_date, :opponent_account_name, :amount)
    Balance = Data.define(:side, :amount)

    def initialize(account)
      @account = account
      @debit_lines = []
      @credit_lines = []
    end

    def add_debit_line(entry_date, opponent_account_name, amount)
      @debit_lines << Line.new(entry_date: entry_date, opponent_account_name: opponent_account_name, amount: amount)
    end

    def add_credit_line(entry_date, opponent_account_name, amount)
      @credit_lines << Line.new(entry_date: entry_date, opponent_account_name: opponent_account_name, amount: amount)
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

  def initialize(company, start_date, end_date)
    @company = company
    raise ArgumentError, "start_date must be a Date" unless start_date.is_a?(Date)
    raise ArgumentError, "end_date must be a Date" unless end_date.is_a?(Date)
    @start_date = start_date
    @end_date = end_date
  end

  def load!
    all_entries = @company.journal_entries.includes(journal_entry_lines: [ :account ]).where(entry_date: @start_date..@end_date).order(:entry_date, :id)
    account_tables = {}

    all_entries.each do |entry|
      debit_lines = entry.journal_entry_lines.filter { |line| line.side == "debit" }
      credit_lines = entry.journal_entry_lines.filter { |line| line.side == "credit" }

      debit_lines.each do |line|
        account_tables[line.account_name] ||= AccountTable.new(line.account)
        account_tables[line.account_name].add_debit_line(entry.entry_date, credit_lines.length == 1 ? credit_lines.first.account_name : "諸口", line.amount)
      end

      credit_lines.each do |line|
        account_tables[line.account_name] ||= AccountTable.new(line.account)
        account_tables[line.account_name].add_credit_line(entry.entry_date, debit_lines.length == 1 ? debit_lines.first.account_name : "諸口", line.amount)
      end
    end

    account_tables
  end
end
