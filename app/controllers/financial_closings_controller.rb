class FinancialClosingsController < ApplicationController
  def new
    company = Current.company
    redirect_to edit_financial_closing_path if company.ongoing_closing.present?

    start_date, end_date = default_closing_date_range(company)
    @financial_closing = FinancialClosing.new(
      company: company,
      start_date: start_date,
      end_date: end_date,
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
    company = Current.company
    @financial_closing = company.ongoing_closing

    case action = params.dig(:financial_closing, :action)
    when "finish_adjustment"
      @financial_closing.closing!
      redirect_to edit_financial_closing_path, notice: "決算整理仕訳の入力が完了しました。"
    when "close"
      @financial_closing.done!
      redirect_to edit_financial_closing_path, notice: "決算処理が完了しました。"
    else
      raise "invalid action #{action} for updating financial closing"
    end
  end

  private

  def default_closing_date_range(company)
    previous_closing = company.financial_closings.order(end_date: :desc).first

    if previous_closing.present?
      start_date = previous_closing.end_date + 1.day
      end_date = start_date + 1.year - 1.day
      return start_date, end_date
    else
      period = AccountingPeriod.from_date(Date.current - 1.year, start_month: company.accounting_period_start_month)
      return period.start_date, period.end_date
    end
  end

  def financial_closing_params
    params.expect(financial_closing: [ :start_date, :end_date ])
  end
end
