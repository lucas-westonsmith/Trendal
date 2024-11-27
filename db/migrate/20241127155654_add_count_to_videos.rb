class AddCountToVideos < ActiveRecord::Migration[7.1]
  def change
    add_reference :videos, :count, null: false, foreign_key: true
  end
end
