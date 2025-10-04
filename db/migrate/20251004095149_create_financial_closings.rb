class CreateFinancialClosings < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_closings do |t|
      t.references :company, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :status

      t.timestamps
    end
  end
end
