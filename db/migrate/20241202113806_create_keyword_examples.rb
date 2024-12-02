class CreateKeywordExamples < ActiveRecord::Migration[7.1]
  def change
    create_table :keyword_examples do |t|
      t.references :trend, null: false, foreign_key: true
      t.text :keyword_phrase
      t.string :most_used_as
      t.float :ctr
      t.text :related_videos

      t.timestamps
    end
  end
end
