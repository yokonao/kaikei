# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

standard_accounts = [
  { name: "現金", category: :asset, is_standard: true },
  { name: "買掛金", category: :liability, is_standard: true },
  { name: "資本金", category: :equity, is_standard: true },
  { name: "売上高", category: :revenue, is_standard: true },
  { name: "仕入高", category: :expense, is_standard: true }
]

standard_accounts.each do |acc|
  Account.create!(**acc)
end
