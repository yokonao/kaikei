class AddCompanyIdToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :company, null: true, foreign_key: true
  end
end
