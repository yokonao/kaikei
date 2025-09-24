class User < ApplicationRecord
  has_one :user_basic_password, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true,
            uniqueness: { message: "は登録済みです" },
            length: { maximum: 254 }, # @see https://www.rfc-editor.org/errata/eid1690
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
