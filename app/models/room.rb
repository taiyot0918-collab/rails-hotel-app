class Room < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :destroy
  has_one_attached :room_image # 施設画像用
  
  # バリデーション（必須項目）
  validates :name, :introduction, :price, :address, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 1 }
  validates :name, presence: true
  validates :introduction, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :address, presence: true
end