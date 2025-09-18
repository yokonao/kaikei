class JournalEntriesController < ApplicationController
  def index
    @journal_entries = JournalEntry.includes(:journal_entry_lines).order(entry_date: :desc, id: :desc)
  end

  def new
    @journal_entry = JournalEntry.new(entry_date: Date.current).tap do |ent|
      ent.journal_entry_lines.build(side: "debit")
      ent.journal_entry_lines.build(side: "credit")
    end
    load_accounts
  end

  def create
    @journal_entry = JournalEntry.new(journal_entry_params)

    if @journal_entry.save
      redirect_to @journal_entry, notice: "仕訳が正常に作成されました。"
    else
      load_accounts
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @journal_entry = JournalEntry.find(params[:id])
    load_accounts
  end

  def update
    @journal_entry = JournalEntry.find(params[:id])

    if @journal_entry.update(journal_entry_params)
      redirect_to @journal_entry, notice: "仕訳が正常に更新されました。"
    else
      load_accounts
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journal_entry = JournalEntry.find(params[:id])
    @journal_entry.destroy
    redirect_to journal_entries_path, notice: "仕訳が削除されました。"
  end

  private

  def journal_entry_params
    params.require(:journal_entry).permit(
      :entry_date,
      :summary,
      journal_entry_lines_attributes: [ :id, :account_id, :amount, :side, :_destroy ]
    )
  end

  def load_accounts
    @accounts = Account.order(:name)
  end
end
