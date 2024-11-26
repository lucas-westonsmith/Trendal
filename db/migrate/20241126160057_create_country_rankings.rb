class CreateCountryRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :country_rankings do |t|
      t.integer :rank
      t.string :country
      t.integer :posts
      t.references :trend, null: false, foreign_key: true

      t.timestamps
    end
  end
end
