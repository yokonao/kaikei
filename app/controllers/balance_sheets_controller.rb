class BalanceSheetsController < ApplicationController
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

    bs = BalanceSheet.new(company: company, start_date: @from, end_date: @to)
    bs.load!

    @asset_lines = bs.asset_lines
    @liability_lines = bs.liability_lines
    @equity_lines = bs.equity_lines
    @total_assets = bs.total_assets
    @total_liabilities = bs.total_liabilities
    @total_equity = bs.total_equity
  end
end
