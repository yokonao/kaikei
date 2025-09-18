class JournalEntriesController < ApplicationController
  def index
    @journal_entries = JournalEntry.includes(:journal_entry_lines).order(entry_date: :desc, id: :desc)
  end

  def destroy
    @journal_entry = JournalEntry.find(params[:id])
    @journal_entry.destroy
    redirect_to journal_entries_path, notice: "仕訳が削除されました。"
  end
end
