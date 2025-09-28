class Company < ApplicationRecord
  has_many :journal_entries

  validates :name, presence: true
end
