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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130822111555) do

  create_table "alert_stats", :force => true do |t|
    t.datetime "last_run"
    t.integer  "count"
    t.integer  "alert_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "alert_stats", ["alert_id"], :name => "index_alert_stats_on_alert_id"

  create_table "alerts", :force => true do |t|
    t.string   "name"
    t.text     "query"
    t.string   "user_id"
    t.string   "alert_type"
    t.integer  "frequency"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "reference"
  end

end
