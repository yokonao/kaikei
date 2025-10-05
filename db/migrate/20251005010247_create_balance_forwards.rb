class CreateBalanceForwards < ActiveRecord::Migration[8.0]
  def change
    create_table :balance_forwards do |t|
      t.references :company, null: false, foreign_key: true
      t.references :financial_closing, null: false, foreign_key: true

      t.string :account_name, null: false, index: true
      t.date :closing_date, null: false
      t.decimal :amount, null: false, precision: 18, scale: 4

      t.foreign_key :accounts, column: :account_name, primary_key: :name

      t.timestamps
    end
  end
end
