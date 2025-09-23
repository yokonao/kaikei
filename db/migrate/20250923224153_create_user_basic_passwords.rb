class CreateUserBasicPasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :user_basic_passwords do |t|
      t.string :password_digest, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
