class AddCompanyIdEmailAddressIndexToInvitations < ActiveRecord::Migration[8.0]
  def change
    change_table :invitations do |t|
      t.index [ :company_id, :email_address ]
    end
  end
end
