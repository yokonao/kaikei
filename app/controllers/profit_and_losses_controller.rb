class ProfitAndLossesController < ApplicationController
  def show
    # TODO: パース失敗時にエラーにならないようにする
    @from = params[:from].present? ? Date.parse(params[:from]) : nil
    @to = params[:to].present? ? Date.parse(params[:to]) : nil

    if @from.nil? && @to.nil?
      @from = fiscal_year_start
      @to = fiscal_year_end(@from)
    elsif @from.nil?
      @from = @to.years_ago(1).days_since(1)
    elsif @to.nil?
      @to = @from.years_since(1).days_ago(1)
    end

    pl = ProfitAndLoss.new(@from, @to)
    pl.load!

    @revenue_lines = pl.revenue_lines
    @expense_lines = pl.expense_lines
    @total_revenue = pl.total_revenue
    @total_expenses = pl.total_expenses
    @net_income = pl.net_income
  end

  private

  # TODO: 将来的には会計年度の開始月をカスタマイズできるようにする
  def fiscal_year_start(today = Date.current)
    if today.month < 4
      Date.new(today.year - 1, 4, 1)
    else
      Date.new(today.year, 4, 1)
    end
  end

  def fiscal_year_end(start_date)
    start_date.years_since(1).days_ago(1)
  end
end
