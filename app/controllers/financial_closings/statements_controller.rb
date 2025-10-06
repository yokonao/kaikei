class FinancialClosings::StatementsController < ApplicationController
  def show
    company = Current.company
    @financial_closing = company.financial_closings.find_by!(id: params[:financial_closing_id])
    @start_date, @end_date = @financial_closing.values_at(:start_date, :end_date)

    @balance_sheet = BalanceSheet.new(company: company, start_date: @start_date, end_date: @end_date)
    @balance_sheet.load!

    @profit_and_loss = ProfitAndLoss.new(company: company, start_date: @start_date, end_date: @end_date)
    @profit_and_loss.load!
  end
end
