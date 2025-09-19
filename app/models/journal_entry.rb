class JournalEntry < ApplicationRecord
  has_many :journal_entry_lines, dependent: :destroy
  accepts_nested_attributes_for :journal_entry_lines, reject_if: :all_blank, allow_destroy: true

  validates :entry_date, presence: true
  validates :summary, length: { maximum: 200 }

  validate :balance_check

  # 借方と貸方の仕訳行数を同じにし、最小行数を保証する
  #
  # @param minimum_lines [Integer] 保証する最小行数（デフォルト: 0）
  # @return [self] メソッドチェーンのため自身を返す
  #
  # @example 基本的な使用例
  #   # 借方2行、貸方1行の場合、貸方に1行追加される
  #   journal_entry.ensure_equal_line_count
  #
  # @example 最小行数を指定
  #   # 借方・貸方それぞれ最低5行を保証
  #   journal_entry.ensure_equal_line_count(5)
  def ensure_equal_line_count(minimum_lines = 0)
    debit_count = journal_entry_lines.count { |line| line.side == "debit" }
    credit_count = journal_entry_lines.count { |line| line.side == "credit" }

    target_lines = [ debit_count, credit_count, minimum_lines ].max

    build_missing_lines("debit", target_lines - debit_count)
    build_missing_lines("credit", target_lines - credit_count)

    self
  end

  private

  def balance_check
    return if journal_entry_lines.empty?

    debit_total = journal_entry_lines.select { |line| line.side == "debit" && line.amount.present? }.sum(&:amount)
    credit_total = journal_entry_lines.select { |line| line.side == "credit" && line.amount.present? }.sum(&:amount)

    if debit_total != credit_total
      errors.add(:base, "借方と貸方の金額が一致していません")
    end
  end

  def build_missing_lines(side, count)
    count.times { journal_entry_lines.build(side: side) }
  end
end
