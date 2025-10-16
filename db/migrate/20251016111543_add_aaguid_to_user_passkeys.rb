class AddAaguidToUserPasskeys < ActiveRecord::Migration[8.0]
  def change
    add_column :user_passkeys, :aaguid, :string, null: false, default: "00000000-0000-0000-0000-000000000000"
  end
end
