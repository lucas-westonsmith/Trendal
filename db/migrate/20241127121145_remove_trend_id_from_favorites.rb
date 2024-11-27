class RemoveTrendIdFromFavorites < ActiveRecord::Migration[7.1]
  def change
    remove_column :favorites, :trend_id, :bigint
  end
end
