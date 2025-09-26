class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false, index: { unique: true }
      t.string :webauthn_user_handle, null: false

      t.timestamps
    end

    create_table :user_basic_passwords do |t|
      t.string :password_digest, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    create_table :user_one_time_passwords do |t|
      t.string :password_digest, null: false
      t.datetime :expires_at, null: false
      t.references :user, null: false, foreign_key: true

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
  end
end
