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

ActiveRecord::Schema[7.1].define(version: 2025_06_23_214554) do
  create_table "friendships", force: :cascade do |t|
    t.integer "requester_id", null: false
    t.integer "receiver_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_friendships_on_receiver_id"
    t.index ["requester_id"], name: "index_friendships_on_requester_id"
  end

  create_table "money_requests", force: :cascade do |t|
    t.integer "requester_id", null: false
    t.integer "recipient_id", null: false
    t.decimal "amount", null: false
    t.string "message"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_money_requests_on_recipient_id"
    t.index ["requester_id"], name: "index_money_requests_on_requester_id"
  end

  create_table "split_participants", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "split_transaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.decimal "share", default: "0.0", null: false
    t.index ["split_transaction_id"], name: "index_split_participants_on_split_transaction_id"
    t.index ["user_id"], name: "index_split_participants_on_user_id"
  end

  create_table "split_transactions", force: :cascade do |t|
    t.integer "creator_id", null: false
    t.decimal "amount"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_split_transactions_on_creator_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.decimal "amount", null: false
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_transactions_on_recipient_id"
    t.index ["sender_id"], name: "index_transactions_on_sender_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "role"
    t.decimal "balance"
    t.boolean "deleted"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "friendships", "users", column: "receiver_id"
  add_foreign_key "friendships", "users", column: "requester_id"
  add_foreign_key "money_requests", "users", column: "recipient_id"
  add_foreign_key "money_requests", "users", column: "requester_id"
  add_foreign_key "split_participants", "split_transactions"
  add_foreign_key "split_participants", "users"
  add_foreign_key "split_transactions", "users", column: "creator_id"
  add_foreign_key "transactions", "users", column: "recipient_id"
  add_foreign_key "transactions", "users", column: "sender_id"
end
