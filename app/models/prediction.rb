class Prediction < ApplicationRecord
  has_many :trends, through: :prediction_trends
end
