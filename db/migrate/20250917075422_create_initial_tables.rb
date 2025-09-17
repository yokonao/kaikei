class CreateInitialTables < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :category, null: false, default: 0

      t.timestamps
    end
  end
end
