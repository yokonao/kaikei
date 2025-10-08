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
  { name: "当座預金", category: :asset, is_standard: true },
  { name: "売掛金", category: :asset, is_standard: true },
  { name: "受取手形", category: :asset, is_standard: true },
  { name: "商品", category: :asset, is_standard: true },
  { name: "建物", category: :asset, is_standard: true },
  { name: "備品", category: :asset, is_standard: true },
  { name: "土地", category: :asset, is_standard: true },
  { name: "貸付金", category: :asset, is_standard: true },
  { name: "繰越商品", category: :asset, is_standard: true },
  { name: "仮払金", category: :asset, is_standard: true },
  { name: "仮払法人税等", category: :asset, is_standard: true },
  { name: "貯蔵品", category: :asset, is_standard: true },

  # 負債科目
  { name: "買掛金", category: :liability, is_standard: true },
  { name: "短期借入金", category: :liability, is_standard: true },
  { name: "未払金", category: :liability, is_standard: true },
  { name: "借入金", category: :liability, is_standard: true },
  { name: "支払手形", category: :liability, is_standard: true },
  { name: "未払法人税等", category: :liability, is_standard: true },
  { name: "前受金", category: :liability, is_standard: true },
  { name: "前受家賃", category: :liability, is_standard: true },
  { name: "未払利息", category: :liability, is_standard: true },

  # 純資産科目
  { name: "資本金", category: :equity, is_standard: true },
  { name: "繰越利益剰余金", category: :equity, is_standard: true },

  # 収益科目
  { name: "売上", category: :revenue, is_standard: true },
  { name: "受取利息", category: :revenue, is_standard: true },
  { name: "受取家賃", category: :revenue, is_standard: true },

  # 費用科目
  { name: "仕入", category: :expense, is_standard: true },
  { name: "給料", category: :expense, is_standard: true },
  { name: "支払利息", category: :expense, is_standard: true },
  { name: "租税公課", category: :expense, is_standard: true },
  { name: "旅費交通費", category: :expense, is_standard: true },
  { name: "通信費", category: :expense, is_standard: true },
  { name: "減価償却費", category: :expense, is_standard: true },
  { name: "貸倒引当金繰入", category: :expense, is_standard: true },
  { name: "法人税、住民税及び事業税", category: :expense, is_standard: true },

  # 集合勘定
  { name: "損益", category: :collective, is_standard: true },

  # 資産の控除科目
  { name: "貸倒引当金", category: :liability, is_standard: true },
  { name: "建物減価償却累計額", category: :liability, is_standard: true },
  { name: "備品減価償却累計額", category: :liability, is_standard: true }
]

standard_accounts.each do |acc|
  Account.find_or_create_by(name: acc[:name]) do |account|
    account.category = acc[:category]
    account.is_standard = acc[:is_standard]
  end
end

puts "勘定科目のサンプルデータを作成しました。"

# 2024年度 期中仕訳
company1.journal_entries.create!(
  entry_date: Date.new(2024, 4, 1),
  summary: "会社設立",
  journal_entry_lines_attributes: [
    { amount: 80000, side: :debit, account: Account.find("現金") },
    { amount: 100000, side: :debit, account: Account.find("当座預金") },
    { amount: 180000, side: :credit, account: Account.find("資本金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2024, 4, 1),
  summary: "銀行から借り入れ",
  journal_entry_lines_attributes: [
    { amount: 200000, side: :debit, account: Account.find("当座預金") },
    { amount: 200000, side: :credit, account: Account.find("借入金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2024, 4, 1),
  summary: "建物の購入（初期投資）",
  journal_entry_lines_attributes: [
    { amount: 160000, side: :debit, account: Account.find("建物") },
    { amount: 160000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2024, 5, 1),
  summary: "A社から商品仕入",
  journal_entry_lines_attributes: [
    { amount: 300000, side: :debit, account: Account.find("仕入") },
    { amount: 125000, side: :credit, account: Account.find("支払手形") },
    { amount: 146000, side: :credit, account: Account.find("買掛金") },
    { amount: 29000, side: :credit, account: Account.find("現金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2024, 6, 12),
  summary: "B社に商品売上",
  journal_entry_lines_attributes: [
    { amount: 45000, side: :debit, account: Account.find("売掛金") },
    { amount: 45000, side: :debit, account: Account.find("受取手形") },
    { amount: 360000, side: :debit, account: Account.find("当座預金") },
    { amount: 450000, side: :credit, account: Account.find("売上") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2024, 9, 1),
  summary: "土地の購入",
  journal_entry_lines_attributes: [
    { amount: 162600, side: :debit, account: Account.find("土地") },
    { amount: 162600, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2024, 10, 10),
  summary: "切手購入",
  journal_entry_lines_attributes: [
    { amount: 200, side: :debit, account: Account.find("通信費") },
    { amount: 200, side: :credit, account: Account.find("現金") }
  ]
)
# 2024年度 決算整理仕訳
company1.journal_entries.create!(
  entry_date: Date.new(2025, 3, 31),
  summary: "建物の減価償却",
  journal_entry_lines_attributes: [
    { amount: 32000, side: :debit, account: Account.find("減価償却費") },
    { amount: 32000, side: :credit, account: Account.find("建物減価償却累計額") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 3, 31),
  summary: "貸倒引当金の積立",
  journal_entry_lines_attributes: [
    { amount: 1800, side: :debit, account: Account.find("貸倒引当金繰入") },
    { amount: 1800, side: :credit, account: Account.find("貸倒引当金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 3, 31),
  summary: "商品繰越",
  journal_entry_lines_attributes: [
    { amount: 150000, side: :debit, account: Account.find("繰越商品") },
    { amount: 150000, side: :credit, account: Account.find("仕入") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 3, 31),
  summary: "法人税計上",
  journal_entry_lines_attributes: [
    { amount: 46000, side: :debit, account: Account.find("法人税、住民税及び事業税") },
    { amount: 46000, side: :credit, account: Account.find("未払法人税等") }
  ]
)
# 2024年度 決算
company1.financial_closings.create!(
  start_date: Date.new(2024, 4, 1),
  end_date: Date.new(2025, 3, 31),
  phase: :closing
).tap do |fc|
  fc.close!
end

# 2025年度 期中仕訳
company1.journal_entries.create!(
  entry_date: Date.new(2025, 5, 1),
  summary: "法人税納付",
  journal_entry_lines_attributes: [
    { amount: 46000, side: :debit, account: Account.find("未払法人税等") },
    { amount: 46000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 6, 23),
  summary: "C社から商品仕入",
  journal_entry_lines_attributes: [
    { amount: 590000, side: :debit, account: Account.find("仕入") },
    { amount: 590000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 6, 24),
  summary: "D社に商品売上",
  journal_entry_lines_attributes: [
    { amount: 110000, side: :debit, account: Account.find("受取手形") },
    { amount: 100000, side: :debit, account: Account.find("売掛金") },
    { amount: 755000, side: :debit, account: Account.find("当座預金") },
    { amount: 965000, side: :credit, account: Account.find("売上") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 7, 10),
  summary: "給料支払い",
  journal_entry_lines_attributes: [
    { amount: 79000, side: :debit, account: Account.find("給料") },
    { amount: 79000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 7, 20),
  summary: "出張費の支払い",
  journal_entry_lines_attributes: [
    { amount: 48000, side: :debit, account: Account.find("旅費交通費") },
    { amount: 48000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 7, 30),
  summary: "印紙購入",
  journal_entry_lines_attributes: [
    { amount: 42500, side: :debit, account: Account.find("租税公課") },
    { amount: 42500, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 8, 3),
  summary: "借入金の利息を支払い",
  journal_entry_lines_attributes: [
    { amount: 5000, side: :debit, account: Account.find("支払利息") },
    { amount: 5000, side: :credit, account: Account.find("現金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 10, 1),
  summary: "法人税の中間納付",
  journal_entry_lines_attributes: [
    { amount: 23000, side: :debit, account: Account.find("仮払法人税等") },
    { amount: 23000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 10, 1),
  summary: "出張のため従業員に仮払い",
  journal_entry_lines_attributes: [
    { amount: 20000, side: :debit, account: Account.find("仮払金") },
    { amount: 20000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2025, 10, 1),
  summary: "備品の購入",
  journal_entry_lines_attributes: [
    { amount: 40000, side: :debit, account: Account.find("備品") },
    { amount: 40000, side: :credit, account: Account.find("当座預金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 2, 1),
  summary: "家賃を受け取り",
  journal_entry_lines_attributes: [
    { amount: 36000, side: :debit, account: Account.find("現金") },
    { amount: 36000, side: :credit, account: Account.find("受取家賃") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 2, 1),
  summary: "利息を受け取り",
  journal_entry_lines_attributes: [
    { amount: 1300, side: :debit, account: Account.find("現金") },
    { amount: 1300, side: :credit, account: Account.find("受取利息") }
  ]
)
# 2025年度 決算整理仕訳
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "商品の繰越",
  journal_entry_lines_attributes: [
    { amount: 150000, side: :debit, account: Account.find("仕入") },
    { amount: 135000, side: :debit, account: Account.find("繰越商品") },
    { amount: 150000, side: :credit, account: Account.find("繰越商品") },
    { amount: 135000, side: :credit, account: Account.find("仕入") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "出張費精算",
  journal_entry_lines_attributes: [
    { amount: 21300, side: :debit, account: Account.find("旅費交通費") },
    { amount: 20000, side: :credit, account: Account.find("仮払金") },
    { amount: 1300, side: :credit, account: Account.find("現金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "手付金の入金を確認",
  journal_entry_lines_attributes: [
    { amount: 38400, side: :debit, account: Account.find("当座預金") },
    { amount: 38400, side: :credit, account: Account.find("前受金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "貸倒引当金の積立",
  journal_entry_lines_attributes: [
    { amount: 4200, side: :debit, account: Account.find("貸倒引当金繰入") },
    { amount: 4200, side: :credit, account: Account.find("貸倒引当金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "建物の減価償却",
  journal_entry_lines_attributes: [
    { amount: 6000, side: :debit, account: Account.find("減価償却費") },
    { amount: 6000, side: :credit, account: Account.find("建物減価償却累計額") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "備品の減価償却",
  journal_entry_lines_attributes: [
    { amount: 3000, side: :debit, account: Account.find("減価償却費") },
    { amount: 3000, side: :credit, account: Account.find("備品減価償却累計額") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "次期分の受取家賃を繰り延べ",
  journal_entry_lines_attributes: [
    { amount: 24000, side: :debit, account: Account.find("受取家賃") },
    { amount: 24000, side: :credit, account: Account.find("前受家賃") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "当期に発生した支払利息の見越し",
  journal_entry_lines_attributes: [
    { amount: 1000, side: :debit, account: Account.find("支払利息") },
    { amount: 1000, side: :credit, account: Account.find("未払利息") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "未使用の収入印紙",
  journal_entry_lines_attributes: [
    { amount: 4850, side: :debit, account: Account.find("貯蔵品") },
    { amount: 4850, side: :credit, account: Account.find("租税公課") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "当座借越の負債計上",
  journal_entry_lines_attributes: [
    { amount: 2000, side: :debit, account: Account.find("当座預金") },
    { amount: 2000, side: :credit, account: Account.find("借入金") }
  ]
)
company1.journal_entries.create!(
  entry_date: Date.new(2026, 3, 31),
  summary: "法人税の算定",
  journal_entry_lines_attributes: [
    { amount: 50000, side: :debit, account: Account.find("法人税、住民税及び事業税") },
    { amount: 23000, side: :credit, account: Account.find("仮払法人税等") },
    { amount: 27000, side: :credit, account: Account.find("未払法人税等") }
  ]
)
company1.financial_closings.create!(
  start_date: Date.new(2025, 4, 1),
  end_date: Date.new(2026, 3, 31),
  phase: :closing
).tap do |fc|
  fc.close!
end

puts "仕訳のサンプルデータを作成しました。"
