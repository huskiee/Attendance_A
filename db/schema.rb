# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20230214190446) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "over_ending_time_at"
    t.boolean "next_day"
    t.string "work_description"
    t.boolean "change"
    t.string "apply_to_superior"
    t.string "overwork_request_status"
    t.string "overwork_info_status"
    t.string "daily_request_status"
    t.string "monthly_request_status"
    t.string "overwork_request_superior"
    t.string "overwork_info_superior"
    t.string "daily_request_superior"
    t.string "monthly_request_superior"
    t.datetime "edit_day_started_at"
    t.datetime "edit_day_finished_at"
    t.datetime "edit_lastday_started_at"
    t.datetime "edit_lastday_finished_at"
    t.boolean "request_change"
    t.boolean "daily_change"
    t.boolean "monthly_change"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "base_number"
    t.string "base_name"
    t.string "base_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "superior", default: false
    t.boolean "admin", default: false
    t.string "department"
    t.string "employee_number"
    t.string "uid"
    t.datetime "basic_work_time", default: "2023-02-14 23:00:00"
    t.datetime "designated_work_time", default: "2023-02-14 22:45:00"
    t.datetime "designated_work_start_time", default: "2023-02-14 23:00:00"
    t.datetime "designated_work_end_time", default: "2023-02-15 07:45:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
