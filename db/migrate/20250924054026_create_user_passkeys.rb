class CreateUserPasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :user_passkeys, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :public_key, null: false
      t.integer :sign_count, null: false
      t.datetime :last_used_at

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
