class FavoritesTrend < ApplicationRecord
  belongs_to :favorite
  belongs_to :trend
end
