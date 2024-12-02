class AddTrendNameToPredictions < ActiveRecord::Migration[7.1]
  def change
    add_column :predictions, :trend_name, :string
  end
end
