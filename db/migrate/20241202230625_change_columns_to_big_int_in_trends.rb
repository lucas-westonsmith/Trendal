class ChangeColumnsToBigIntInTrends < ActiveRecord::Migration[7.1]
  def change
    change_column :trends, :engagement_count, :bigint
    change_column :trends, :count, :bigint
    change_column :trends, :view_count, :bigint
    change_column :trends, :like_count, :bigint
    change_column :trends, :impression_count, :bigint
    change_column :trends, :cost, :bigint
  end
end
