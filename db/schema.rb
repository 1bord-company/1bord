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

ActiveRecord::Schema[7.0].define(version: 2023_08_11_060059) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account/companies", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "account/people", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_account/people_on_company_id"
  end

  create_table "account/users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.bigint "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_account/users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_account/users_on_email", unique: true
    t.index ["person_id"], name: "index_account/users_on_person_id"
    t.index ["reset_password_token"], name: "index_account/users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_account/users_on_unlock_token", unique: true
  end

  create_table "core/personas", force: :cascade do |t|
    t.string "name"
    t.string "external_type"
    t.string "external_id"
    t.string "provider"
    t.bigint "account__person_id", null: false
    t.jsonb "external_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account__person_id"], name: "index_core/personas_on_account__person_id"
  end

  create_table "core/resources", force: :cascade do |t|
    t.string "name"
    t.string "external_type"
    t.string "external_id"
    t.string "provider"
    t.bigint "account__company_id", null: false
    t.jsonb "external_data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account__company_id"], name: "index_core/resources_on_account__company_id"
  end

  add_foreign_key "account/people", "account/companies", column: "company_id"
  add_foreign_key "account/users", "account/people", column: "person_id"
  add_foreign_key "core/personas", "account/people", column: "account__person_id"
  add_foreign_key "core/resources", "account/companies", column: "account__company_id"
end
