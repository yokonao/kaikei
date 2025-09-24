class CreateUserOneTimePasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :user_one_time_passwords do |t|
      t.string :password_digest, null: false
      t.datetime :expires_at, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
