class AddYoutubeAttributesToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :hashtags, :string
    add_column :trends, :video_duration, :string
    add_column :trends, :published_at, :datetime
    add_column :trends, :channel_name, :string
  end
end
