class AddRankToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :rank, :integer
  end
end
