class AddCountryToKeywordExamples < ActiveRecord::Migration[7.1]
  def change
    add_column :keyword_examples, :country, :string
  end
end
