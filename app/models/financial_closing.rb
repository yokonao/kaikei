class FinancialClosing < ApplicationRecord
  belongs_to :company
  has_many :balance_forwards

  enum :phase, {
    adjusting: 1, # 決算整理仕訳を行うフェーズ
    closing: 2, # 帳簿の締め切りを行うフェーズ
    done: 3 # 決算処理完了を意味する
  }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :phase, presence: true
  validate :validate_start_and_end_date

  def validate_start_and_end_date
    return unless start_date && end_date

    if start_date >= end_date
      errors.add(:base, "決算の終了日は開始日より後の日付を指定してください")
      return
    end

    # 会社計算規則第59条2項（令和7年3月31日施行）
    # https://laws.e-gov.go.jp/law/418M60000010013#Mp-Pa_3-Ch_1-Se_2-At_59
    # 各事業年度に係る計算書類及びその附属明細書の作成に係る期間は、当該事業年度の前事業年度の末日の翌日（当該事業年度の前事業年度がない場合にあっては、成立の日）から当該事業年度の末日までの期間とする。
    # この場合において、当該期間は、一年（事業年度の末日を変更する場合における変更後の最初の事業年度については、一年六箇月）を超えることができない。
    if start_date + 18.months <= end_date
      errors.add(:base, "決算期間は1年半以内にしなければいけません")
      return
    end

    other_closings = FinancialClosing.where(company_id: company_id).order(end_date: :desc)
    other_closings = other_closings.where.not(id: id) if persisted?
    return if other_closings.empty?

    latest_closing_end_date = other_closings.first.end_date

    unless start_date == latest_closing_end_date + 1.day
      errors.add(:base, "決算の開始日は前回決算の終了日の翌日にしてください")
    end
  end

  def close!
    gl = GeneralLedger.new(company: company, start_date: start_date, end_date: end_date)
    gl.load!

    # 収益・費用を損益勘定に振り替える
    pl_account = Account.find("損益")
    revenue_tranfer_entry = JournalEntry.new(company: company, entry_date: end_date, summary: "決算振替仕訳（収益 → 損益）")
    revenue_balance = 0
    expense_transfer_entry = JournalEntry.new(company: company, entry_date: end_date, summary: "決算振替仕訳（費用 → 損益）")
    expense_balance = 0
    gl.account_tables.values.each do |account_table|
      account = account_table.account
      amount = account_table.balance.amount
      if account.revenue?
        case account_table.balance.side
        when "debit"
          revenue_balance -= amount
          revenue_tranfer_entry.journal_entry_lines.build(account: account, side: "credit", amount: amount)
        when "credit"
          revenue_balance += amount
          revenue_tranfer_entry.journal_entry_lines.build(account: account, side: "debit", amount: amount)
        end
      elsif account.expense?
        case account_table.balance.side
        when "debit"
          expense_balance += amount
          expense_transfer_entry.journal_entry_lines.build(account: account, side: "credit", amount: amount)
        when "credit"
          expense_balance -= amount
          expense_transfer_entry.journal_entry_lines.build(account: account, side: "debit", amount: amount)
        end
      end
    end

    if revenue_balance != 0
      side = revenue_balance.positive? ? "credit" : "debit"
      revenue_tranfer_entry.journal_entry_lines.build(account: pl_account, side: side, amount: revenue_balance.abs)
      revenue_tranfer_entry.save!
    end
    if expense_balance != 0
      side = expense_balance.positive? ? "debit" : "credit"
      expense_transfer_entry.journal_entry_lines.build(account: pl_account, side: side, amount: expense_balance.abs)
      expense_transfer_entry.save!
    end

    # 損益勘定を繰越利益剰余金に振り替える
    pl_balance = revenue_balance - expense_balance
    if pl_balance != 0
      JournalEntry.create!(
        company: company,
        entry_date: end_date,
        summary: "決算振替仕訳（損益 → 繰越利益剰余金）",
        journal_entry_lines_attributes: [
          { account: pl_account, side: pl_balance.positive? ? "debit" : "credit", amount: pl_balance.abs },
          { account: Account.find("繰越利益剰余金"), side: pl_balance.positive? ? "credit" : "debit", amount: pl_balance.abs }
        ]
      )
    end

    # B/S 残高を次期に繰り越す
    ActiveRecord::Base.transaction do
      gl.load! # 仕訳が追加されているのでリロードする
      gl.account_tables.values.each do |account_table|
        account = account_table.account
        if account.asset? || account.liability? || account.equity?
          balance_forwards.create!(company: company, closing_date: end_date, account: account, amount: account_table.balance.amount)
        end
      end
    end

    done!
  end
end
