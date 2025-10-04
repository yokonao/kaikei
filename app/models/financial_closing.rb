class FinancialClosing < ApplicationRecord
  belongs_to :company

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
  end
end
