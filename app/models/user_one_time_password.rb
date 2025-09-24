class UserOneTimePassword < ApplicationRecord
  belongs_to :user

  has_secure_password
  validates :expires_at, presence: true

  def self.authenticate_otp(user_id, otp)
    record = where("expires_at > ?", Time.current).order(id: :desc).authenticate_by(user_id: user_id, password: otp)
    return false unless record
    record.destroy!
    true
  end
end
