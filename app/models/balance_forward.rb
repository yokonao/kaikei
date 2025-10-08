class BalanceForward < ApplicationRecord
  belongs_to :company
  belongs_to :financial_closing
  belongs_to :account, foreign_key: :account_name, primary_key: :name

  validates :closing_date, presence: true
  validates :amount, numericality: { greater_than: 0 }

  enum :side, {
    debit: "debit",
    credit: "credit"
  }

  # 逆側の side を取得するメソッド
  def opposite_side
    case side
    when "debit"
      "credit"
    when "credit"
      "debit"
    else
      side
    end
  end
end
