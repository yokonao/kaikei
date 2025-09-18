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
  # 資産科目
  { name: "現金", category: :asset, is_standard: true },
  { name: "普通預金", category: :asset, is_standard: true },
  { name: "売掛金", category: :asset, is_standard: true },
  { name: "商品", category: :asset, is_standard: true },

  # 負債科目
  { name: "買掛金", category: :liability, is_standard: true },
  { name: "短期借入金", category: :liability, is_standard: true },
  { name: "未払金", category: :liability, is_standard: true },

  # 純資産科目
  { name: "資本金", category: :equity, is_standard: true },
  { name: "利益剰余金", category: :equity, is_standard: true },

  # 収益科目
  { name: "売上高", category: :revenue, is_standard: true },
  { name: "受取利息", category: :revenue, is_standard: true },

  # 費用科目
  { name: "仕入高", category: :expense, is_standard: true },
  { name: "給料手当", category: :expense, is_standard: true },
  { name: "支払利息", category: :expense, is_standard: true },
  { name: "租税公課", category: :expense, is_standard: true },
  { name: "旅費交通費", category: :expense, is_standard: true },
  { name: "通信費", category: :expense, is_standard: true }
]

standard_accounts.each do |acc|
  Account.find_or_create_by(name: acc[:name]) do |account|
    account.category = acc[:category]
    account.is_standard = acc[:is_standard]
  end
end

puts "勘定科目のサンプルデータを作成しました。"
