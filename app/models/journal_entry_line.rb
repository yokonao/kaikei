class JournalEntryLine < ApplicationRecord
  belongs_to :journal_entry
  belongs_to :account, foreign_key: :account_name, primary_key: :name

  validates :amount, numericality: { greater_than: 0, less_than_or_equal_to: 999_999_999_999 }

  enum :side, {
    debit: "debit",
    credit: "credit"
  }

  # 金額入力フォームの初期値となる値
  # 整数の場合は小数点以下を表示しないようにしている
  def formatted_amount_for_input
    self.amount&.to_s&.sub(/\.0+$/, "")
  end
end
