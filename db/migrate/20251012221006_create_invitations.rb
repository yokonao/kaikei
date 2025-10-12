class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.references :company, null: false, foreign_key: true

      t.string :emal_address
      t.string :inviter_email_address
      t.boolean :accepted

      t.timestamps
    end
  end
end
