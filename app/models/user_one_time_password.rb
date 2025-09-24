class UserOneTimePassword < ApplicationRecord
  belongs_to :user

  has_secure_password
  validates :expires_at, presence: true
end
