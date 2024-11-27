class Favorite < ApplicationRecord
  belongs_to :user
  has_many :favorites_trends
  has_many :trends, through: :favorites_trends
end

