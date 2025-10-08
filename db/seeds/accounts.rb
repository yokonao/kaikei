# 資産科目
asset_accounts = [
  "現金",
  "小口現金",
  "普通預金",
  "当座預金",
  "定期預金",
  "受取手形",
  "電子記録債権",
  "繰越商品",
  "売掛金",
  "クレジット売掛金",
  "貸付金",
  "手形貸付金",
  "従業員貸付金",
  "役員貸付金",
  "未収入金",
  "前払金",
  "仮払金",
  "立替金",
  "受取商品券",
  "差入保証金",
  "建物",
  "土地",
  "備品",
  "車両運搬具",
  "貯蔵品",
  "仮払法人税等",
  "仮払消費税",
  "前払費用",
  "未収収益",
  # 控除科目
  "貸倒引当金",
  "減価償却累計額",
  "建物減価償却累計額",
  "備品減価償却累計額",
  "車両運搬具減価償却累計額"
]
asset_accounts.each do |name|
  Account.find_or_create_by!(name: name) do |account|
    account.category = :asset
    account.is_standard = true
  end
end

liability_accounts = [
  "買掛金",
  "支払手形",
  "当座借越",
  "借入金",
  "役員借入金",
  "手形借入金",
  "電子記録債務",
  "未払金",
  "前受金",
  "仮受金",
  "預り金",
  "従業員預り金",
  "未払配当金",
  "未払法人税等",
  "仮受消費税",
  "未払消費税",
  "未払配当金",
  "未払費用",
  "未払家賃",
  "未払利息",
  "未払地代",
  "前受収益",
  "前受家賃",
  "前受利息",
  "前受地代"
]
liability_accounts.each do |name|
  Account.find_or_create_by!(name: name) do |account|
    account.category = :liability
    account.is_standard = true
  end
end

equity_accounts = [
  "資本金",
  "利益準備金",
  "繰越利益剰余金"
]
equity_accounts.each do |name|
  Account.find_or_create_by!(name: name) do |account|
    account.category = :equity
    account.is_standard = true
  end
end

revenue_accounts = [
  "売上",
  "商品売買益",
  "有価証券利息",
  "貸倒引当金戻入",
  "償却債権取立益",
  "固定資産売却益",
  "受取利息",
  "受取家賃",
  "受取地代",
  "受取配当金",
  "雑収入"
]
revenue_accounts.each do |name|
  Account.find_or_create_by!(name: name) do |account|
    account.category = :revenue
    account.is_standard = true
  end
end

expense_accounts = [
  "仕入",
  "発送費",
  "通信費",
  "修繕費",
  "支払保険料",
  "広告費",
  "支払手数料",
  "支払利息",
  "旅費交通費",
  "給料",
  "消耗品費",
  "租税公課",
  "法定福利費",
  "貸倒損失",
  "貸倒引当金繰入",
  "減価償却費",
  "固定資産売却損",
  "支払家賃",
  "雑費",
  "法人税、住民税及び事業税"
]
expense_accounts.each do |name|
  Account.find_or_create_by!(name: name) do |account|
    account.category = :expense
    account.is_standard = true
  end
end

other_accounts = [
  # 集合勘定
  { name: "損益", category: :collective, is_standard: true }
  # TODO: 現金過不足を追加する
]
other_accounts.each do |acc|
  Account.find_or_create_by!(name: acc[:name]) do |account|
    account.category = acc[:category]
    account.is_standard = acc[:is_standard]
  end
end

puts "デフォルト勘定科目データを作成しました。"
