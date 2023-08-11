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

ActiveRecord::Schema[7.0].define(version: 2023_08_11_095022) do
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

  create_table "core/roles", force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.bigint "resource_id", null: false
    t.bigint "persona_id", null: false
    t.datetime "onboard_at", precision: nil
    t.datetime "onboarded_at", precision: nil
    t.datetime "offboard_at", precision: nil
    t.datetime "offboarded_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["persona_id"], name: "index_core/roles_on_persona_id"
    t.index ["resource_id"], name: "index_core/roles_on_resource_id"
  end

  create_table "sync/api_calls", force: :cascade do |t|
    t.bigint "token_id", null: false
    t.string "endpoint"
    t.string "method"
    t.jsonb "request_headers"
    t.jsonb "request_body"
    t.jsonb "response_headers"
    t.jsonb "response_body"
    t.integer "duration_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_id"], name: "index_sync/api_calls_on_token_id"
  end

  create_table "sync/tokens", force: :cascade do |t|
    t.string "token"
    t.string "type"
    t.string "provider"
    t.string "scope"
    t.string "authorizer_type"
    t.bigint "authorizer_id"
    t.bigint "account__company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account__company_id"], name: "index_sync/tokens_on_account__company_id"
  end

  create_table "xapp/bots", force: :cascade do |t|
    t.string "provider"
    t.string "external_id"
    t.bigint "account__company_id", null: false
    t.jsonb "external_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account__company_id"], name: "index_xapp/bots_on_account__company_id"
  end

  create_table "xapp/redirects", force: :cascade do |t|
    t.string "endpoint"
    t.jsonb "params"
    t.bigint "bot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bot_id"], name: "index_xapp/redirects_on_bot_id"
  end

  create_table "xapp/webhooks", force: :cascade do |t|
    t.string "endpoint"
    t.jsonb "payload"
    t.jsonb "headers"
    t.bigint "bot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bot_id"], name: "index_xapp/webhooks_on_bot_id"
  end

  add_foreign_key "account/people", "account/companies", column: "company_id"
  add_foreign_key "account/users", "account/people", column: "person_id"
  add_foreign_key "core/personas", "account/people", column: "account__person_id"
  add_foreign_key "core/resources", "account/companies", column: "account__company_id"
  add_foreign_key "core/roles", "core/personas", column: "persona_id"
  add_foreign_key "core/roles", "core/resources", column: "resource_id"
  add_foreign_key "sync/api_calls", "sync/tokens", column: "token_id"
  add_foreign_key "sync/tokens", "account/companies", column: "account__company_id"
  add_foreign_key "xapp/bots", "account/companies", column: "account__company_id"
  add_foreign_key "xapp/redirects", "xapp/bots", column: "bot_id"
  add_foreign_key "xapp/webhooks", "xapp/bots", column: "bot_id"
end
