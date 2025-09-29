# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user1 = User.create!(email_address: "test@example.com")
user2 = User.create!(email_address: "test2@example.com")

company1 = Company.create!(name: "テスト事業所1")
company2 = Company.create!(name: "テスト事業所2")
company3 = Company.create!(name: "テスト事業所3")

Membership.create!(user: user1, company: company1)
Membership.create!(user: user1, company: company2)
Membership.create!(user: user1, company: company3)
Membership.create!(user: user2, company: company1)

standard_accounts = [
  # 資産科目
  { name: "現金", category: :asset, is_standard: true },
  { name: "普通預金", category: :asset, is_standard: true },
  { name: "売掛金", category: :asset, is_standard: true },
  { name: "商品", category: :asset, is_standard: true },
  { name: "建物", category: :asset, is_standard: true },
  { name: "土地", category: :asset, is_standard: true },
  { name: "貸付金", category: :asset, is_standard: true },

  # 負債科目
  { name: "買掛金", category: :liability, is_standard: true },
  { name: "短期借入金", category: :liability, is_standard: true },
  { name: "未払金", category: :liability, is_standard: true },
  { name: "借入金", category: :liability, is_standard: true },

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

company1.journal_entries.create!(
  entry_date: Date.new(2025, 9, 1),
  summary: "会社設立",
  journal_entry_lines_attributes: [
    { amount: 3000, side: :debit, account: Account.find("現金") },
    { amount: 3000, side: :credit, account: Account.find("資本金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 9, 2),
  summary: "銀行から借り入れ",
  journal_entry_lines_attributes: [
    { amount: 2000, side: :debit, account: Account.find("現金") },
    { amount: 2000, side: :credit, account: Account.find("借入金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 9, 13),
  summary: "建物・土地の購入",
  journal_entry_lines_attributes: [
    { amount: 700, side: :debit, account: Account.find("建物") },
    { amount: 1700, side: :credit, account: Account.find("資本金") },
    { amount: 1000, side: :debit, account: Account.find("土地") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 9, 14),
  summary: "取引先への貸し付け",
  journal_entry_lines_attributes: [
    { amount: 1000, side: :debit, account: Account.find("貸付金") },
    { amount: 1000, side: :credit, account: Account.find("現金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 9, 16),
  summary: "商品の仕入れ",
  journal_entry_lines_attributes: [
    { amount: 2700, side: :debit, account: Account.find("仕入高") },
    { amount: 2700, side: :credit, account: Account.find("現金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 9, 17),
  summary: "商品の売却",
  journal_entry_lines_attributes: [
    { amount: 4000, side: :debit, account: Account.find("現金") },
    { amount: 4000, side: :credit, account: Account.find("売上高") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 9, 25),
  summary: "従業員への給与支払い",
  journal_entry_lines_attributes: [
    { amount: 800, side: :debit, account: Account.find("給料手当") },
    { amount: 800, side: :credit, account: Account.find("現金") }
  ]
)

puts "仕訳のサンプルデータを作成しました。"
