class AddYoutubeDataToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :view_count, :integer
    add_column :trends, :like_count, :integer
  end
end
