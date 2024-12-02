class AddScrapedFieldsToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :popularity, :integer
    add_column :trends, :popularity_change, :float
    add_column :trends, :ctr, :float
    add_column :trends, :cvr, :float
    add_column :trends, :cpa, :float
    add_column :trends, :cost, :integer
    add_column :trends, :impression_count, :integer
    add_column :trends, :view_rate_6s, :float
    add_column :trends, :share_count, :integer
    add_column :trends, :comment_count, :integer
  end
end
