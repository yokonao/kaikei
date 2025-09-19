class ProfitAndLossStatementsController < ApplicationController
  def index
    # ダミーデータを設定（実際の計算ロジックは後で実装）
    @revenue_accounts = [
      { name: "売上高", amount: 10000000 },
      { name: "受取利息", amount: 50000 }
    ]

    @expense_accounts = [
      { name: "売上原価", amount: 6000000 },
      { name: "給料手当", amount: 2000000 },
      { name: "地代家賃", amount: 500000 },
      { name: "水道光熱費", amount: 200000 },
      { name: "通信費", amount: 100000 },
      { name: "減価償却費", amount: 300000 }
    ]

    @total_revenue = @revenue_accounts.sum { |account| account[:amount] }
    @total_expenses = @expense_accounts.sum { |account| account[:amount] }
    @net_income = @total_revenue - @total_expenses
  end
end