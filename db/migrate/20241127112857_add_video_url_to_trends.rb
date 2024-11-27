class AddVideoUrlToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :video_url, :string
  end
end
