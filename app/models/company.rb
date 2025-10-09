class Company < ApplicationRecord
  has_many :balance_forwards
  has_many :journal_entries
  has_many :financial_closings

  validates :name, presence: true
  validates :accounting_period_start_month, inclusion: { in: (1..12), message: "は1月から12月のいずれかを指定してください" }

  attribute :accounting_period_start_month, :integer, default: 4

  def ongoing_closing
    financial_closings.where.not(phase: :done).take
  end

  def incinerate!
    Company::Incineration.new(self).run
  end
end
