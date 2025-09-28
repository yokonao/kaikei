class AddCompanyIdToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_reference :journal_entries, :company, null: false, foreign_key: true
  end
end
