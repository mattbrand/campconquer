# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160906154744) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "activities", force: :cascade do |t|
    t.integer  "player_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "steps",                    default: 0,     null: false
    t.integer  "steps_claimed",            default: 0,     null: false
    t.integer  "vigorous_minutes",         default: 0,     null: false
    t.integer  "moderate_minutes",         default: 0,     null: false
    t.boolean  "moderate_minutes_claimed", default: false, null: false
    t.boolean  "vigorous_minutes_claimed", default: false, null: false
  end

  add_index "activities", ["date"], name: "index_activities_on_date"
  add_index "activities", ["player_id"], name: "index_activities_on_player_id"

  create_table "games", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "locked"
    t.boolean  "current",    default: false
    t.integer  "season_id"
    t.string   "state",      default: "preparing"
  end

  add_index "games", ["current"], name: "index_games_on_current"
  add_index "games", ["season_id"], name: "index_games_on_season_id"

  create_table "gears", force: :cascade do |t|
    t.string  "name"
    t.string  "display_name"
    t.string  "description"
    t.integer "health_bonus"
    t.integer "speed_bonus"
    t.integer "range_bonus"
    t.string  "gear_type"
    t.string  "asset_name"
    t.string  "icon_name"
    t.integer "gold",         default: 0, null: false
    t.integer "gems",         default: 0, null: false
    t.integer "level",        default: 0, null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer "piece_id",                 null: false
    t.integer "gear_id",                  null: false
    t.boolean "equipped", default: false, null: false
  end

  add_index "items", ["piece_id", "gear_id"], name: "index_items_on_piece_id_and_gear_id"

  create_table "outcomes", force: :cascade do |t|
    t.string   "winner"
    t.integer  "match_length"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "game_id"
    t.text     "moves"
  end

  add_index "outcomes", ["game_id"], name: "index_outcomes_on_game_id"

  create_table "pieces", force: :cascade do |t|
    t.string   "team"
    t.string   "role"
    t.text     "path"
    t.float    "speed"
    t.integer  "health"
    t.float    "range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "game_id"
    t.integer  "player_id"
    t.string   "body_type"
  end

  create_table "player_outcomes", force: :cascade do |t|
    t.string   "team"
    t.integer  "takedowns"
    t.integer  "throws"
    t.integer  "pickups"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "outcome_id"
    t.integer  "player_id"
    t.integer  "flag_carry_distance", null: false
    t.integer  "captures",            null: false
    t.integer  "attack_mvp",          null: false
    t.integer  "defend_mvp",          null: false
  end

  add_index "player_outcomes", ["outcome_id"], name: "index_player_outcomes_on_outcome_id"
  add_index "player_outcomes", ["player_id"], name: "index_player_outcomes_on_player_id"

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "team"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "fitbit_token_hash"
    t.string   "anti_forgery_token"
    t.integer  "coins",              default: 0, null: false
    t.integer  "gems",               default: 0, null: false
    t.integer  "user_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "current",    default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
