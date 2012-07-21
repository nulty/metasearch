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

ActiveRecord::Schema.define(:version => 20120718200138) do

  create_table "googles", :force => true do |t|
    t.text     "query"
    t.integer  "query_rank"
    t.integer  "query_number"
    t.text     "title"
    t.text     "description"
    t.text     "url"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "results", :force => true do |t|
    t.text     "session_id"
    t.text     "db_name"
    t.text     "query"
    t.integer  "query_rank"
    t.text     "title"
    t.text     "description"
    t.text     "url"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "query_number"
  end

end
