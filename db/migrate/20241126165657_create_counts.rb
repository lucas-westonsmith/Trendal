class CreateCounts < ActiveRecord::Migration[7.1]
  def change
    create_table :counts do |t|
      t.references :trend, null: false, foreign_key: true
      t.string :country
      t.integer :period
      t.integer :number

      t.timestamps
    end
  end
end
