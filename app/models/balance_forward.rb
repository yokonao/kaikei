class BalanceForward < ApplicationRecord
  belongs_to :company
  belongs_to :financial_closing
  belongs_to :account, foreign_key: :account_name, primary_key: :name

  validates :closing_date, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
