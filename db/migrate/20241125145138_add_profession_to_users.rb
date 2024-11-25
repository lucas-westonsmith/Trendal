class AddProfessionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :profession, :string
  end
end
