class UserPasskey < ApplicationRecord
  belongs_to :user

  validates :public_key, presence: true
  validates :sign_count, presence: true
end
