class ProfitAndLossStatementsController < ApplicationController
  def index
    profit_and_loss = ProfitAndLoss.new(nil, nil)
    @revenue_accounts = profit_and_loss.revenue_accounts
    @expense_accounts = profit_and_loss.expense_accounts

    @total_revenue = @revenue_accounts.sum { |account| account.amount }
    @total_expenses = @expense_accounts.sum { |account| account.amount }
    @net_income = @total_revenue - @total_expenses
  end
end
