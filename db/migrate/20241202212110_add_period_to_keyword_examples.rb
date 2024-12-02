class AddPeriodToKeywordExamples < ActiveRecord::Migration[7.1]
  def change
    add_column :keyword_examples, :period, :integer
  end
end
