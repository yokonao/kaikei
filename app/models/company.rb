class Company < ApplicationRecord
  has_many :journal_entries

  validates :name, presence: true
  validates :fy_start_month_num, inclusion: { in: (1..12), message: "は1月から12月のいずれかを指定してください" }

  attribute :fy_start_month_num, :integer, default: 4
end
