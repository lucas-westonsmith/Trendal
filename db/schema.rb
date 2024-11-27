# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_11_27_163440) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "counts", force: :cascade do |t|
    t.bigint "trend_id", null: false
    t.string "country"
    t.integer "period"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trend_id"], name: "index_counts_on_trend_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "favorites_trends", force: :cascade do |t|
    t.bigint "favorite_id", null: false
    t.bigint "trend_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favorite_id"], name: "index_favorites_trends_on_favorite_id"
    t.index ["trend_id"], name: "index_favorites_trends_on_trend_id"
  end

  create_table "prediction_trends", force: :cascade do |t|
    t.bigint "trend_id", null: false
    t.bigint "prediction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prediction_id"], name: "index_prediction_trends_on_prediction_id"
    t.index ["trend_id"], name: "index_prediction_trends_on_trend_id"
  end

  create_table "predictions", force: :cascade do |t|
    t.text "description"
    t.integer "confidence_score"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trends", force: :cascade do |t|
    t.string "title"
    t.integer "engagement_count"
    t.integer "count"
    t.string "location"
    t.string "platform"
    t.text "description"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rank"
    t.integer "count_overall"
    t.integer "view_count"
    t.integer "like_count"
    t.string "industry"
    t.string "hashtags"
    t.string "video_duration"
    t.datetime "published_at"
    t.string "channel_name"
    t.string "video_url"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "profession"
    t.string "company"
    t.date "date_of_birth"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.string "url"
    t.bigint "trend_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "count_id"
    t.index ["count_id"], name: "index_videos_on_count_id"
    t.index ["trend_id"], name: "index_videos_on_trend_id"
  end

  add_foreign_key "counts", "trends"
  add_foreign_key "favorites", "users"
  add_foreign_key "favorites_trends", "favorites"
  add_foreign_key "favorites_trends", "trends"
  add_foreign_key "prediction_trends", "predictions"
  add_foreign_key "prediction_trends", "trends"
  add_foreign_key "videos", "counts"
  add_foreign_key "videos", "trends"
end
