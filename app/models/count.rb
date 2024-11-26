class Count < ApplicationRecord
  belongs_to :trend

  COUNTRY_MAPPING = {
    'PT' => ['Portugal', '🇵🇹'],
    'US' => ['United States', '🇺🇸'],
    'GB' => ['United Kingdom', '🇬🇧'],
    'FR' => ['France', '🇫🇷'],
    'ES' => ['Spain', '🇪🇸'],
    'IT' => ['Italy', '🇮🇹']
  }.freeze

  # Retourne le nom complet et le drapeau du pays
  def country_name_with_flag
    name, flag = COUNTRY_MAPPING[country] || [country, '🏳️']
    "#{flag} #{name}"
  end

  # Formate les nombres comme K/M selon leur taille
  def formatted_number
    case number
    when 1_000_000..Float::INFINITY
      # Si le nombre est un million ou plus, on l'affiche en millions
      value = (number / 1_000_000.0).round(1)
      value == value.to_i ? "#{value.to_i}M" : "#{value}M"  # Supprime les décimales si l'entier est exact
    when 1_000..999_999
      # Si le nombre est dans la plage des milliers, on l'affiche en milliers
      value = (number / 1_000.0).round(1)
      value == value.to_i ? "#{value.to_i}K" : "#{value}K"  # Supprime les décimales si l'entier est exact
    else
      # Sinon, c'est un nombre pur
      number.to_s
    end
  end
end
