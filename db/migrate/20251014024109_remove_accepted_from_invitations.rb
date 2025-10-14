class RemoveAcceptedFromInvitations < ActiveRecord::Migration[8.0]
  def change
    change_table :invitations do |t|
      t.remove :accepted
    end
  end
end
