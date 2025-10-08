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
  Account.find_or_create_by!(name: acc[:name]) do |account|
    account.category = acc[:category]
    account.is_standard = acc[:is_standard]
  end
end

puts "勘定科目のサンプルデータを作成しました。"
