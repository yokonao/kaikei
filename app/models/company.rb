class Company < ApplicationRecord
  has_many :journal_entries

  validates :name, presence: true
  validates :accounting_period_start_month, inclusion: { in: (1..12), message: "は1月から12月のいずれかを指定してください" }

  attribute :accounting_period_start_month, :integer, default: 4
end
