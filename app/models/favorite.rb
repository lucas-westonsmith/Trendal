class Favorite < ApplicationRecord
  belongs_to :user
  has_many :favorites_trends, dependent: :destroy
  has_many :trends, through: :favorites_trends
end
