module FinancialClosings::StatementsHelper
  def format_amount(v)
    number_to_currency(v, unit: "", delimiter: ",").gsub(/\.0+$/, "").sub("-", "△ ")
  end
end
