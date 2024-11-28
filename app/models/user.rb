class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :favorite
  has_one_attached :avatar
  has_many :trends, through: :favorite
  after_create :create_user_favorite

  private

  def create_user_favorite
    Favorite.create(user: self)
  end
end
