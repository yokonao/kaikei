class DropUserBasicPasswords < ActiveRecord::Migration[8.0]
  def change
    drop_table :user_basic_passwords
  end
end
