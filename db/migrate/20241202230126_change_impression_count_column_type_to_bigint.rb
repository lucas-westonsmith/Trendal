class ChangeImpressionCountColumnTypeToBigint < ActiveRecord::Migration[7.1]
  def change
    change_column :trends, :impression_count, :bigint
  end
end
