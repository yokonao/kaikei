class AddUniqueConstraintToUserOneTimePasswordsUser < ActiveRecord::Migration[8.0]
  def change
    change_table :user_one_time_passwords do |t|
      t.remove_references :user
      t.references :user, null: false, foreign_key: true, index: { unique: true }
    end
  end
end
