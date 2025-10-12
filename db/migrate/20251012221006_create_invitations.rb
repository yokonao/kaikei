class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.references :company, null: false, foreign_key: true

      t.string :email_address, null: false
      t.string :inviter_email_address, null: false
      t.boolean :accepted, null: false, default: false

      t.timestamps
    end
  end
end
