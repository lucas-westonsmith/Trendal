class CreatePredictionTrends < ActiveRecord::Migration[7.1]
  def change
    create_table :prediction_trends do |t|
      t.references :trend, null: false, foreign_key: true
      t.references :prediction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
