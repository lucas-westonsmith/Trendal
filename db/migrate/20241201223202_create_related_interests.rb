class CreateRelatedInterests < ActiveRecord::Migration[7.1]
  def change
    create_table :related_interests do |t|
      t.references :trend, null: false, foreign_key: true
      t.references :count, null: false, foreign_key: true

      t.timestamps
    end
  end
end
