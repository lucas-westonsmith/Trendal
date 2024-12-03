class Trend < ApplicationRecord
  has_many :prediction_trends
  has_many :predictions, through: :prediction_trends
  has_many :counts, dependent: :destroy
  has_many :favorites_trends
  has_many :favorites, through: :favorites_trends
  has_many :users, through: :favorite_trends
  has_many :videos, through: :counts
  has_many :related_interests, through: :counts
  validates :platform, presence: true
  validates :industry, presence: false
  has_many :keyword_examples, dependent: :destroy

  def formatted_count(count)
    return "NA" if count.nil?
    if count >= 1_000_000_000
      formatted = (count / 1_000_000_000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}B" : "#{formatted}B"
    elsif count >= 1_000_000
      formatted = (count / 1_000_000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}M" : "#{formatted}M"
    elsif count >= 1_000
      formatted = (count / 1000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}K" : "#{formatted}K"
    else
      count.to_s
    end
  end


  def formatted_count_integer(count)
    return "NA" if count.nil?
    if count >= 1_000_000_000
      formatted = (count / 1_000_000_000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}B" : "#{formatted}B"
    elsif count >= 1_000_000
      formatted = (count / 1_000_000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}M" : "#{formatted}M"
    elsif count >= 1_000
      formatted = (count / 1000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}K" : "#{formatted}K"
    else
      count.to_s
    end
  end
end
