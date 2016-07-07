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

ActiveRecord::Schema.define(version: 20160707220644) do

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "locked"
  end

  create_table "outcomes", force: :cascade do |t|
    t.string   "winner"
    t.integer  "team_stats_id"
    t.integer  "match_length"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_outcomes", force: :cascade do |t|
    t.string   "team"
    t.integer  "takedowns"
    t.integer  "throws"
    t.integer  "pickups"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
