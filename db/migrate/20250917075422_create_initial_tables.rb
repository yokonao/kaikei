class CreateInitialTables < ActiveRecord::Migration[8.0]
  def change
    # ユーザー関連テーブル
    create_table :users do |t|
      t.string :email_address, null: false, index: { unique: true }
      t.string :webauthn_user_handle, null: false

      t.timestamps
    end

    create_table :user_one_time_passwords do |t|
      t.string :password_digest, null: false
      t.datetime :expires_at, null: false
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end

    create_table :user_passkeys, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :public_key, null: false
      t.integer :sign_count, null: false
      t.datetime :last_used_at

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # 事業所関連テーブル
    create_table :companies do |t|
      t.string :name
      t.integer :fy_start_month_num, null: false

      t.timestamps
    end

    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps

      t.index [ :user_id, :company_id ], unique: true
    end

    # セッション関連テーブル
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: true, foreign_key: true

      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    # 会計データ関連テーブル
    create_table :accounts, id: false do |t|
      t.string :name, null: false, primary_key: true
      t.integer :category, null: false, default: 0, comment: "区分（資産・負債・純資産・収益・費用）"
      t.boolean :is_standard, null: false, comment: "システム標準の勘定科目なら true、ユーザーが独自に追加したカスタム勘定科目なら false"

      t.timestamps
    end

    create_table :journal_entries do |t|
      t.references :company, null: false, foreign_key: true

      t.date :entry_date, null: false
      t.string :summary, comment: "摘要"

      t.timestamps
    end

    create_table :journal_entry_lines do |t|
      t.decimal :amount, null: false, precision: 18, scale: 4
      t.string :side, null: false, comment: "debit(借方) または credit(貸方)"

      t.references :journal_entry, null: false, foreign_key: { on_delete: :cascade }
      t.string :account_name, null: false, index: true

      t.foreign_key :accounts, column: :account_name, primary_key: :name

      t.timestamps
    end
  end
end
