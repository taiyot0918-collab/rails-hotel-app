class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # 必須項目のバリデーション
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :person_count, presence: true, numericality: { greater_than_or_equal_to: 1 } # 1人以上

  # 日付の整合性チェック（独自のメソッドを呼び出す）
  validate :start_date_after_today
  validate :end_date_after_start_date

  private

  # チェックイン日が本日以降か
  def start_date_after_today
    return if start_date.blank?
    if start_date < Date.today
      errors.add(:start_date, "は本日以降の日付を選択してください")
    end
  end

  # チェックアウト日がチェックイン日より後か
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date <= start_date
      errors.add(:end_date, "はチェックイン日より後の日付を選択してください")
    end
  end
end