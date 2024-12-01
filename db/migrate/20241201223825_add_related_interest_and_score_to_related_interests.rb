class AddRelatedInterestAndScoreToRelatedInterests < ActiveRecord::Migration[7.1]
  def change
    add_column :related_interests, :title, :string
    add_column :related_interests, :score, :integer
  end
end
