class ProfitAndLossStatementsController < ApplicationController
  def index
    pl = ProfitAndLoss.new(Date.new(2024, 4, 1), Date.new(2025, 3, 31))
    pl.load!
    @revenu_lines = pl.revenu_lines
    @expense_lines = pl.expense_lines

    @total_revenue = @revenu_lines.sum { |account| account.amount }
    @total_expenses = @expense_lines.sum { |account| account.amount }
    @net_income = @total_revenue - @total_expenses
  end
end
