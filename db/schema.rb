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

ActiveRecord::Schema[7.1].define(version: 2026_08_03_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bottle_wishlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "bottle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bottle_id"], name: "index_bottle_wishlists_on_bottle_id"
    t.index ["user_id", "bottle_id"], name: "index_bottle_wishlists_on_user_id_and_bottle_id", unique: true
    t.index ["user_id"], name: "index_bottle_wishlists_on_user_id"
  end

  create_table "bottles", force: :cascade do |t|
    t.string "name", null: false
    t.string "distillery", null: false
    t.integer "age"
    t.decimal "final_score", precision: 3, scale: 1
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "meeting_id"
    t.datetime "revealed_at"
    t.string "bottle_type"
    t.decimal "cached_average_rating", precision: 3, scale: 2
    t.integer "ratings_count", default: 0, null: false
    t.index ["cached_average_rating"], name: "index_bottles_on_cached_average_rating"
    t.index ["meeting_id"], name: "index_bottles_on_meeting_id"
    t.index ["user_id"], name: "index_bottles_on_user_id"
  end

  create_table "meeting_attendees", force: :cascade do |t|
    t.bigint "meeting_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_id", "user_id"], name: "index_meeting_attendees_on_meeting_id_and_user_id", unique: true
    t.index ["meeting_id"], name: "index_meeting_attendees_on_meeting_id"
    t.index ["user_id"], name: "index_meeting_attendees_on_user_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.date "date", null: false
    t.bigint "bottle_bringer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "attendees_count", default: 0, null: false
    t.boolean "is_flight", default: false, null: false
    t.text "notes"
    t.index ["bottle_bringer_id"], name: "index_meetings_on_bottle_bringer_id"
    t.index ["date"], name: "index_meetings_on_date"
  end

  create_table "ratings", force: :cascade do |t|
    t.decimal "score", precision: 5, scale: 3, default: "0.0", null: false
    t.text "comment"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bottle_id", null: false
    t.text "flavors"
    t.index ["bottle_id"], name: "index_ratings_on_bottle_id"
    t.index ["user_id", "bottle_id"], name: "index_ratings_on_user_id_and_bottle_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bottle_wishlists", "bottles"
  add_foreign_key "bottle_wishlists", "users"
  add_foreign_key "bottles", "meetings"
  add_foreign_key "bottles", "users"
  add_foreign_key "meeting_attendees", "meetings"
  add_foreign_key "meeting_attendees", "users"
  add_foreign_key "meetings", "users", column: "bottle_bringer_id"
  add_foreign_key "ratings", "bottles"
  add_foreign_key "ratings", "users"
end
