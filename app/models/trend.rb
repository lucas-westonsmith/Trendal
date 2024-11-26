class Trend < ApplicationRecord
  has_many :predictions, through: :prediction_trends
  has_many :counts

  # Méthode pour formater le nombre avec suffixe K ou M
  def formatted_count(count)
    if count >= 1_000_000
      # Format en millions, sans décimales si le résultat est entier
      formatted = (count / 1_000_000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}M" : "#{formatted}M"
    elsif count >= 1_000
      # Format en milliers, sans décimales si le résultat est entier
      formatted = (count / 1000.0).round(1)
      formatted == formatted.to_i ? "#{formatted.to_i}K" : "#{formatted}K"
    else
      count.to_s  # Si moins de 1000, retourne simplement le nombre
    end
  end
end
