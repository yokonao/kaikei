class ProfitAndLossesController < ApplicationController
  def show
    company = Current.company
    @from = (Date.parse(params[:from]) rescue nil)
    @to = (Date.parse(params[:to]) rescue nil)

    if @from.nil? && @to.nil?
      period = AccountingPeriod.from_date(Date.current, start_month: company.accounting_period_start_month)
      @from = period.start_date
      @to = period.end_date
    elsif @from.nil?
      @from = @to.years_ago(1).days_since(1)
    elsif @to.nil?
      @to = @from.years_since(1).days_ago(1)
    end

    pl = ProfitAndLoss.new(Current.company, @from, @to)
    pl.load!

    @revenue_lines = pl.revenue_lines
    @expense_lines = pl.expense_lines
    @total_revenue = pl.total_revenue
    @total_expenses = pl.total_expenses
    @net_income = pl.net_income
  end
end
