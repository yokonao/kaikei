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

ActiveRecord::Schema[8.0].define(version: 2025_09_24_054026) do
  create_table "accounts", primary_key: "name", id: :string, force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.boolean "is_standard", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journal_entries", force: :cascade do |t|
    t.date "entry_date", null: false
    t.string "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journal_entry_lines", force: :cascade do |t|
    t.decimal "amount", precision: 18, scale: 4, null: false
    t.string "side", null: false
    t.integer "journal_entry_id", null: false
    t.string "account_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_name"], name: "index_journal_entry_lines_on_account_name"
    t.index ["journal_entry_id"], name: "index_journal_entry_lines_on_journal_entry_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_basic_passwords", force: :cascade do |t|
    t.string "password_digest", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_basic_passwords_on_user_id"
  end

  create_table "user_one_time_passwords", force: :cascade do |t|
    t.string "password_digest", null: false
    t.datetime "expires_at", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_one_time_passwords_on_user_id"
  end

  create_table "user_passkeys", id: :string, force: :cascade do |t|
    t.string "public_key", null: false
    t.integer "sign_count", null: false
    t.datetime "last_used_at"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_passkeys_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "journal_entry_lines", "accounts", column: "account_name", primary_key: "name"
  add_foreign_key "journal_entry_lines", "journal_entries", on_delete: :cascade
  add_foreign_key "sessions", "users"
  add_foreign_key "user_basic_passwords", "users"
  add_foreign_key "user_one_time_passwords", "users"
  add_foreign_key "user_passkeys", "users"
end
