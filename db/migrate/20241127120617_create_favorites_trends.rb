class CreateFavoritesTrends < ActiveRecord::Migration[7.1]
  def change
    create_table :favorites_trends do |t|
      t.references :favorite, null: false, foreign_key: true
      t.references :trend, null: false, foreign_key: true

      t.timestamps
    end
  end
end
