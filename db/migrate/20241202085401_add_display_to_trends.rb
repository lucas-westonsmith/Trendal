class AddDisplayToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :display, :boolean
  end
end
