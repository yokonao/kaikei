name = "テスト事業所1"
company1 = Company.find_by!(name: name)

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

puts "#{name} 2025年度の仕訳を作成しました。"
