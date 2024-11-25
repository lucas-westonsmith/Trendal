class CreatePredictions < ActiveRecord::Migration[7.1]
  def change
    create_table :predictions do |t|
      t.text :description
      t.integer :confidence_score
      t.string :title

      t.timestamps
    end
  end
end
