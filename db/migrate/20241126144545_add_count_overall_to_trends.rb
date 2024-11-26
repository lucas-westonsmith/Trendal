class AddCountOverallToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :count_overall, :integer
  end
end
