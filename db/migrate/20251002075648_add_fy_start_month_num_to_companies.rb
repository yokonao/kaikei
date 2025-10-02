class AddFyStartMonthNumToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :fy_start_month_num, :integer
  end
end
