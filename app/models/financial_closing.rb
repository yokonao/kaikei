class FinancialClosing < ApplicationRecord
  belongs_to :company

  enum :phase, {
    adjusting: 1, # 決算整理仕訳を行うフェーズ
    closing: 2, # 帳簿の締め切りを行うフェーズ
    done: 3 # 決算処理完了を意味する
  }
end
