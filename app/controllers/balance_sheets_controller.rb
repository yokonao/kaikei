class BalanceSheetsController < ApplicationController
  def show
    @from = (Date.parse(params[:from]) rescue nil)
    @to = (Date.parse(params[:to]) rescue nil)

    if @from.nil? && @to.nil?
      @from = fiscal_year_start
      @to = fiscal_year_end(@from)
    elsif @from.nil?
      @from = @to.years_ago(1).days_since(1)
    elsif @to.nil?
      @to = @from.years_since(1).days_ago(1)
    end

    bs = BalanceSheet.new(Current.company, @from, @to)
    bs.load!

    @asset_lines = bs.asset_lines
    @liability_lines = bs.liability_lines
    @equity_lines = bs.equity_lines
    @total_assets = bs.total_assets
    @total_liabilities = bs.total_liabilities
    @total_equity = bs.total_equity
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

  def fiscal_year_end(today = Date.current)
    fiscal_year_start(today).years_since(1).days_ago(1)
  end
end
