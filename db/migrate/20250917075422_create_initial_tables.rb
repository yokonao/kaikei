class CreateInitialTables < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :category, null: false, default: 0
      t.boolean :is_standard, null: false

      t.timestamps
    end
  end
end
