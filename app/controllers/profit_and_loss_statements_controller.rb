class ProfitAndLossStatementsController < ApplicationController
  def index
    pl = ProfitAndLoss.new(Date.new(2024, 4, 1), Date.new(2025, 3, 31))
    pl.load!

    @revenue_lines = pl.revenue_lines
    @expense_lines = pl.expense_lines
    @total_revenue = pl.total_revenue
    @total_expenses = pl.total_expenses
    @net_income = pl.net_income
  end
end
