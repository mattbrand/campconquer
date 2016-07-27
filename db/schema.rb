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

ActiveRecord::Schema.define(version: 20160727153258) do

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

  create_table "games", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "locked"
    t.boolean  "current",    default: false
  end

  add_index "games", ["current"], name: "index_games_on_current"

  create_table "outcomes", force: :cascade do |t|
    t.string   "winner"
    t.integer  "match_length"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "game_id"
  end

  add_index "outcomes", ["game_id"], name: "index_outcomes_on_game_id"

  create_table "pieces", force: :cascade do |t|
    t.string   "team"
    t.string   "job"
    t.string   "role"
    t.text     "path"
    t.float    "speed"
    t.integer  "hit_points"
    t.float    "range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "game_id"
    t.integer  "player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "team"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "fitbit_token_hash"
    t.string   "anti_forgery_token"
  end

  create_table "team_outcomes", force: :cascade do |t|
    t.string   "team"
    t.integer  "takedowns"
    t.integer  "throws"
    t.integer  "pickups"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "team_stats_id"
    t.integer  "outcome_id"
  end

  add_index "team_outcomes", ["outcome_id"], name: "index_team_outcomes_on_outcome_id"

end
