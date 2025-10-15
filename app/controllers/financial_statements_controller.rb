class FinancialStatementsController < ApplicationController
  def show
    company = target_company
    @financial_closing = company.financial_closings.find(params[:id])
    @start_date, @end_date = @financial_closing.values_at(:start_date, :end_date)
    @financial_statement = FinancialStatement.new(company: company, financial_closing: @financial_closing)
    @financial_statement.load!
  end
end
