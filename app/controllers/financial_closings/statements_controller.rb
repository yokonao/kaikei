class FinancialClosings::StatementsController < ApplicationController
  def show
    company = Current.company
    @financial_closing = company.financial_closings.find_by!(id: params[:financial_closing_id])
    @start_date, @end_date = @financial_closing.values_at(:start_date, :end_date)

    @balance_sheet = BalanceSheet.new(company: company, start_date: @start_date, end_date: @end_date)
    @balance_sheet.load!

    @bs_debit_lines = []
    @balance_sheet.asset_lines.each do |line|
      @bs_debit_lines << [ line.name, line.amount ]
    end

    @bs_credit_lines = []
    @balance_sheet.liability_lines.each do |line|
      @bs_credit_lines << [ line.name, line.amount ]
    end
    @balance_sheet.equity_lines.each do |line|
      @bs_credit_lines << [ line.name, line.amount ]
    end


    @profit_and_loss = ProfitAndLoss.new(company: company, start_date: @start_date, end_date: @end_date, exclude_closing_entry: true)
    @profit_and_loss.load!

    @pl_debit_lines = []
    @profit_and_loss.expense_lines.each do |line|
      @pl_debit_lines << [ line.name, line.amount ]
    end
    @pl_total_debit = @profit_and_loss.total_expenses

    @pl_credit_lines = []
    @profit_and_loss.revenue_lines.each do |line|
      @pl_credit_lines << [ line.name, line.amount ]
    end
    @pl_total_credit = @profit_and_loss.total_revenue

    net_income = @profit_and_loss.net_income
    if net_income > 0
      @pl_debit_lines << [ "当期純利益", net_income ]
      @pl_total_debit += net_income
    elsif net_income < 0
      loss = net_income.abs
      @pl_credit_lines << [ "当期純損失", loss ]
      @pl_total_credit += loss
    end
  end
end
