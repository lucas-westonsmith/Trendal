class AddIndustryToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :industry, :string
  end
end
