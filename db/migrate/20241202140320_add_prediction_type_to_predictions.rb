class AddPredictionTypeToPredictions < ActiveRecord::Migration[7.1]
  def change
    add_column :predictions, :prediction_type, :string, default: 'general'
  end
end
