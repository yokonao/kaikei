name = "テスト事業所1"
company1 = Company.find_by!(name: name)

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

puts "#{name} 2024年度の仕訳を作成しました。"
