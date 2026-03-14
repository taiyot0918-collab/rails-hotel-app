class User < ApplicationRecord
  # Deviseの設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ここを追記：1人のユーザーは1つのアイコン画像を持てる
  has_one_attached :icon_image
  
  # ここを追記：リレーション
  has_many :rooms, dependent: :destroy
  has_many :reservations, dependent: :destroy
end