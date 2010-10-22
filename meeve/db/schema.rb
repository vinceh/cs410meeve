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

ActiveRecord::Schema.define(:version => 20101022022539) do

  create_table "events", :primary_key => "eid", :force => true do |t|
    t.string  "pic"
    t.string  "desc",     :default => "", :null => false
    t.string  "location", :default => "", :null => false
    t.date    "start",                    :null => false
    t.date    "end",                      :null => false
    t.integer "flag"
  end

  create_table "testtable", :id => false, :force => true do |t|
    t.integer "random"
  end

  create_table "user_event", :primary_key => "ue_id", :force => true do |t|
    t.string  "title",  :default => "",   :null => false
    t.boolean "active", :default => true, :null => false
    t.text    "body",                     :null => false
    t.integer "eid"
  end
  
  add_index "user_event", ["eid"], :name => "eid"

end
