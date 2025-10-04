class FinancialClosingsController < ApplicationController
  def new
    company = Current.company
    redirect_to edit_financial_closing_path if company.ongoing_closing.present?

    # TODO: 開始日、終了日は現在の日付と事業所の状態などからいい感じに推測する
    @financial_closing = FinancialClosing.new(
      company: company,
      start_date: Date.new(2024, 4, 1),
      end_date: Date.new(2025, 3, 31),
      phase: :adjusting
    )
  end

  def create
    company = Current.company
    start_date, end_date = financial_closing_params.values_at(:start_date, :end_date)
    @financial_closing = FinancialClosing.new(
      company: company,
      start_date: start_date,
      end_date: end_date,
      phase: :adjusting
    )

    if @financial_closing.save
      redirect_to edit_financial_closing_path, notice: "決算処理を開始します。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    company = Current.company
    @financial_closing = company.ongoing_closing
    redirect_to new_financial_closing_path unless @financial_closing.present?
  end

  def update
  end

  private

  def financial_closing_params
    params.expect(financial_closing: [ :start_date, :end_date ])
  end
end
