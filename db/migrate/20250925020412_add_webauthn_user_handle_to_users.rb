class AddWebauthnUserHandleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :webauthn_user_handle, :string
  end
end
