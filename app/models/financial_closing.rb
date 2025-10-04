class FinancialClosing < ApplicationRecord
  belongs_to :company

  enum :phase, {
    adjusting: 1, # 決算整理仕訳を行うフェーズ
    closing: 2, # 帳簿の締め切りを行うフェーズ
    done: 3 # 決算処理完了を意味する
  }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :phase, presence: true
  validate :validate_start_and_end_date

  def validate_start_and_end_date
    return unless start_date && end_date

    if start_date >= end_date
      errors.add(:base, "決算の終了日は開始日より後の日付を指定してください")
      return
    end

    # 会社計算規則第59条2項（令和7年3月31日施行）
    # https://laws.e-gov.go.jp/law/418M60000010013#Mp-Pa_3-Ch_1-Se_2-At_59
    # 各事業年度に係る計算書類及びその附属明細書の作成に係る期間は、当該事業年度の前事業年度の末日の翌日（当該事業年度の前事業年度がない場合にあっては、成立の日）から当該事業年度の末日までの期間とする。
    # この場合において、当該期間は、一年（事業年度の末日を変更する場合における変更後の最初の事業年度については、一年六箇月）を超えることができない。
    if start_date + 18.months <= end_date
      errors.add(:base, "決算期間は1年半以内にしなければいけません")
      return
    end

    other_closings = FinancialClosing.where(company_id: company_id).order(end_date: :desc)
    other_closings = other_closings.where.not(id: id) if persisted?
    return if other_closings.empty?

    latest_closing_end_date = other_closings.first.end_date

    unless start_date == latest_closing_end_date + 1.day
      errors.add(:base, "決算の開始日は前回決算の終了日の翌日にしてください")
    end
  end
end
