class ChangeCountIdToAllowNullInVideos < ActiveRecord::Migration[7.1]
  def change
    change_column_null :videos, :count_id, true
  end
end
