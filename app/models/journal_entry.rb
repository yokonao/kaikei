class JournalEntry < ApplicationRecord
  has_many :journal_entry_lines, dependent: :destroy

  validates :entry_date, presence: true
  validates :summary, length: { maximum: 200 }
end
