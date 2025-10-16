class UserPasskey < ApplicationRecord
  belongs_to :user

  validates :display_name, presence: true
  validates :public_key, presence: true
  validates :sign_count, presence: true

  def autofill_display_name!
    self.display_name = "パスキー#{self.incremental_index}"
  end

  private

  # ユーザーが保有するパスキーの数 + 1 を返す
  def incremental_index
    UserPasskey.where(user_id: self.user_id).count + 1
  end
end
