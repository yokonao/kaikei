class JournalEntry < ApplicationRecord
  has_many :journal_entry_lines, dependent: :destroy
  accepts_nested_attributes_for :journal_entry_lines, reject_if: :all_blank, allow_destroy: true

  validates :entry_date, presence: true
  validates :summary, length: { maximum: 200 }

  validate :balance_check

  private

  def balance_check
    return if journal_entry_lines.empty?

    debit_total = journal_entry_lines.select { |line| line.side == "debit" }.sum(&:amount)
    credit_total = journal_entry_lines.select { |line| line.side == "credit" }.sum(&:amount)

    if debit_total != credit_total
      errors.add(:base, "借方と貸方の金額が一致していません")
    end
  end
end
