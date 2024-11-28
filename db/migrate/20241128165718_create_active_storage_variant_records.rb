class CreateActiveStorageVariantRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :active_storage_variant_records do |t|
      t.bigint :blob_id, null: false
      t.string :variation_digest, null: false

      t.index [:blob_id, :variation_digest], unique: true, name: "index_active_storage_variant_records_uniqueness"
    end
  end
end
