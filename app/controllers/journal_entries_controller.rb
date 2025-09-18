class JournalEntriesController < ApplicationController
  def index
    @journal_entries = JournalEntry.includes(:journal_entry_lines).order(entry_date: :desc, id: :desc)
  end
end
