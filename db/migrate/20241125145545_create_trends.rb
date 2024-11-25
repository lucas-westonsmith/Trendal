class CreateTrends < ActiveRecord::Migration[7.1]
  def change
    create_table :trends do |t|
      t.string :title
      t.integer :engagement_count
      t.integer :count
      t.string :location
      t.string :platform
      t.text :description
      t.date :date

      t.timestamps
    end
  end
end
