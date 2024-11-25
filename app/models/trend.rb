class Trend < ApplicationRecord
  has_many :predictions, through: :prediction_trends
end
