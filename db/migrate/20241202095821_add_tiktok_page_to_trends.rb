class AddTiktokPageToTrends < ActiveRecord::Migration[7.1]
  def change
    add_column :trends, :tiktok_page, :string
  end
end
