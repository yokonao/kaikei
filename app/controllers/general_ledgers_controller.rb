class GeneralLedgersController < ApplicationController
  def show
    company = target_company
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

    @gl = GeneralLedger.new(company: company, start_date: @from, end_date: @to)
    @gl.load!
  end
end
