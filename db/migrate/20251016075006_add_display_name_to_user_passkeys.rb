class AddDisplayNameToUserPasskeys < ActiveRecord::Migration[8.0]
  def change
    add_column :user_passkeys, :display_name, :string, null: false
  end
end
