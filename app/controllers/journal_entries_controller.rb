class JournalEntriesController < ApplicationController
  DEFAULT_LINES_PARAMS = 5
  MAX_LINES_PARAMS = 1000

  def index
    @journal_entries = Current.company.journal_entries.
      includes(:journal_entry_lines).
      order(entry_date: :desc, id: :desc).
      page(params[:page]).
      per(5)
  end

  def new
    @journal_entry = Current.company.journal_entries.build(entry_date: Date.current)
    prepare_journal_entry_detail
  end

  def create
    @journal_entry = Current.company.journal_entries.build(journal_entry_params)

    if @journal_entry.save
      redirect_to edit_journal_entry_path(@journal_entry), notice: "仕訳が正常に作成されました。"
    else
      prepare_journal_entry_detail
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @journal_entry = Current.company.journal_entries.find_by!(id: params[:id])
    prepare_journal_entry_detail
  end

  def update
    @journal_entry = Current.company.journal_entries.find_by!(id: params[:id])

    if @journal_entry.update(journal_entry_params)
      redirect_to edit_journal_entry_path(@journal_entry), notice: "仕訳が正常に更新されました。"
    else
      prepare_journal_entry_detail
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journal_entry = Current.company.journal_entries.find_by!(id: params[:id])
    @journal_entry.destroy
    redirect_to journal_entries_path, notice: "仕訳が削除されました。"
  end

  private

  def journal_entry_params
    params.require(:journal_entry).permit(
      :entry_date,
      :summary,
      journal_entry_lines_attributes: [ :id, :account_name, :amount, :side, :_destroy ]
    ).tap do |p|
      p[:journal_entry_lines_attributes].reject! { |k, v| v["id"].blank? && v["account_name"].blank? && v["amount"].blank? }
      p[:journal_entry_lines_attributes].each do |k, v|
        v["_destroy"] = "1" if v["account_name"].blank? && v["amount"].blank?
      end
    end
  end

  # 仕訳詳細画面を描画するのに必要なセットアップを全てまとめて行う
  def prepare_journal_entry_detail
    raise "@journal_entry must be set" if @journal_entry.blank?
    @journal_entry.ensure_equal_line_count(lines_params)
    @journal_entry = @journal_entry
    @journal_entry_lines = organize_journal_entry_lines(@journal_entry)
    @accounts = Account.order(:name)
  end

  def lines_params
    p = params[:lines].try(:to_i)
    return DEFAULT_LINES_PARAMS if !p.is_a?(Integer) || p <= 0
    return MAX_LINES_PARAMS if p >= MAX_LINES_PARAMS
    p
  end

  # 仕訳の明細行を借方行 → 貸方行 → 借方行 → 貸方行 ... という順番に並び替える
  #
  # @note 貸借の明細行を一致させてからこのメソッドを呼び出すこと
  def organize_journal_entry_lines(journal_entry)
    debit_lines = journal_entry.journal_entry_lines.select { |line| line.side == "debit" }
    credit_lines = journal_entry.journal_entry_lines.select { |line| line.side == "credit" }
    debit_lines.zip(credit_lines).flatten
  end
end
