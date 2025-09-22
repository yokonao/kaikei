class ProfitAndLoss
  Line = Data.define(:name, :amount)

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def revenue_accounts
    [
      Line.new(name: "売上高", amount: 10000000),
      Line.new(name: "受取利息", amount: 50000)
    ]
  end

  def expense_accounts
    [
      Line.new(name: "売上原価", amount: 6000000),
      Line.new(name: "給料手当", amount: 2000000),
      Line.new(name: "地代家賃", amount: 500000),
      Line.new(name: "水道光熱費", amount: 200000),
      Line.new(name: "通信費", amount: 100000),
      Line.new(name: "減価償却費", amount: 300000)
    ]
  end
end
