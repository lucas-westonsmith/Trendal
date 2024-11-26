class DropCountryRankings < ActiveRecord::Migration[7.1]
  def change
    drop_table :country_rankings
  end
end
