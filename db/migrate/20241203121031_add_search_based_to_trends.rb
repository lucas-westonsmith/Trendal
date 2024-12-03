class AddSearchBasedToTrends < ActiveRecord::Migration[6.0]
  def change
    add_column :trends, :search_based, :boolean, default: false
  end
end
