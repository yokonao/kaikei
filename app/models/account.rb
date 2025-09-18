class Account < ApplicationRecord
  enum :category, {
    asset: 1, # 資産
    liability: 2, # 負債
    equity: 3, # 資本
    revenue: 4, # 収益
    expense: 5 # 費用
  }

  validates :name,
            presence: true,
            length: { maximum: 50 },
            uniqueness: { message: "が重複しています" }
  validates :category, presence: { message: "を指定してください" }
  validates :is_standard, inclusion: { in: [ true, false ], message: "は真偽値で指定してください" }
end
