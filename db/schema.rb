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

ActiveRecord::Schema.define(version: 20170105202606) do

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
    t.integer  "steps",                  default: 0,     null: false
    t.integer  "steps_claimed",          default: 0,     null: false
    t.integer  "active_minutes",         default: 0,     null: false
    t.boolean  "active_minutes_claimed", default: false, null: false
  end

  add_index "activities", ["date"], name: "index_activities_on_date"
  add_index "activities", ["player_id"], name: "index_activities_on_player_id"

  create_table "games", force: :cascade do |t|
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "current",         default: false
    t.integer  "season_id"
    t.string   "state",           default: "preparing"
    t.text     "moves"
    t.string   "winner"
    t.integer  "match_length",    default: 0,           null: false
    t.datetime "scheduled_start"
    t.text     "mvps"
    t.datetime "played_at"
  end

  add_index "games", ["current"], name: "index_games_on_current"
  add_index "games", ["season_id"], name: "index_games_on_season_id"

  create_table "items", force: :cascade do |t|
    t.integer "piece_id",                  null: false
    t.boolean "equipped",  default: false, null: false
    t.string  "gear_name"
  end

  add_index "items", ["piece_id"], name: "index_items_on_piece_id_and_gear_id"

  create_table "outcomes", force: :cascade do |t|
    t.string   "team"
    t.integer  "takedowns"
    t.integer  "throws"
    t.integer  "pickups"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "player_id"
    t.integer  "flag_carry_distance",                 null: false
    t.integer  "captures",                            null: false
    t.integer  "game_id"
    t.boolean  "attack_mvp",          default: false, null: false
    t.boolean  "defend_mvp",          default: false, null: false
  end

  add_index "outcomes", ["game_id"], name: "index_outcomes_on_game_id"
  add_index "outcomes", ["player_id"], name: "index_outcomes_on_player_id"

  create_table "pieces", force: :cascade do |t|
    t.string   "team"
    t.string   "role"
    t.text     "path"
    t.integer  "speed",      default: 0, null: false
    t.integer  "health",     default: 0, null: false
    t.integer  "range",      default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "game_id"
    t.integer  "player_id"
    t.string   "body_type"
    t.string   "face"
    t.string   "hair"
    t.string   "skin_color"
    t.string   "hair_color"
    t.text     "ammo"
  end

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "team"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.text     "fitbit_token_hash"
    t.string   "anti_forgery_token"
    t.integer  "coins",                default: 0,     null: false
    t.integer  "gems",                 default: 0,     null: false
    t.boolean  "embodied",             default: false, null: false
    t.string   "session_token"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",                default: false, null: false
    t.datetime "activities_synced_at"
  end

  add_index "players", ["session_token"], name: "index_players_on_session_token"

  create_table "seasons", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "current",    default: false, null: false
    t.date     "start_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer  "player_id"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["player_id"], name: "index_sessions_on_player_id"
  add_index "sessions", ["token"], name: "index_sessions_on_token"

end
