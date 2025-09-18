class JournalEntryLine < ApplicationRecord
  belongs_to :journal_entry
  belongs_to :account

  validates :amount, numericality: { greater_than: 0 }
  validates :side, inclusion: { in: [ "debit", "credit" ], message: "は debit または credit で指定してください" }
end
