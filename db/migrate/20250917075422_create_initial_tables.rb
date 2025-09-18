class CreateInitialTables < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :category, null: false, default: 0, comment: "区分（資産・負債・純資産・収益・費用）"
      t.boolean :is_standard, null: false, comment: "システム標準の勘定科目なら true、ユーザーが独自に追加したカスタム勘定科目なら false"

      t.timestamps
    end

    create_table :journal_entries do |t|
      t.date :entry_date, null: false
      t.string :summary, comment: "摘要"

      t.timestamps
    end

    create_table :journal_entry_lines do |t|
      t.decimal :amount, null: false, precision: 18, scale: 4
      t.string :side, null: false, comment: "debit(借方) または credit(貸方)"

      t.references :journal_entry, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
