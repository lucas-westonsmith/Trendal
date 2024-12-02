class Prediction < ApplicationRecord
  has_many :prediction_trends
  has_many :trends, through: :prediction_trends
end
