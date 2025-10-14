class AddCompanyIdEmailAddressUniqueIndexToInvitations < ActiveRecord::Migration[8.0]
  def change
    change_table :invitations do |t|
      t.remove_index [ :company_id, :email_address ]
      t.index [ :company_id, :email_address ], unique: true
    end
  end
end
