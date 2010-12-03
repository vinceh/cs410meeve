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
  
  create_table "accounts", :primary_key => "aid", :force => true do |t|
  	t.datetime "last_login", :default => Time.now
  	t.string "login_name", :default => "", :null => false
  	t.string "password", :null => false
  	t.string "first_name", :default => "", :null => false
  	t.string "last_name", :default => "", :null => false
  	t.boolean "active", :default => true, :null => false
  	t.string "email", :default => ""
  	t.string "phone_number", :default => ""
  	t.boolean "facebook", :default => false, :null => false
  	t.string "gcal", :default => "", :null => false
  end
  
# A relationship table
  create_table "follows", :id => false, :force => true do |t|
  	t.integer "follower", :null => false
  	t.integer "followee", :null => false
  end
  
  add_index "follows", ["follower"], :name => "follower"
  add_index "follows", ["followee"], :name => "followee"

  create_table "events", :primary_key => "event_id", :force => true do |t|
    t.integer   "aid",                          :null => false
    t.string    "pic"
    t.string    "title",                        :null => false
    t.string    "desc",     :default => "",     :null => false
    t.string    "location", :default => "",     :null => false
    t.string    "marker_lat"
    t.string    "marker_lng"
    t.datetime  "start_date",                   :null => false
    t.datetime  "end_date",                     :null => false
    t.integer   "flag"
    t.string "gevent", :default => "", :null => false
  end

  create_table "joinevents", :primary_key => "jeid", :force => true do |t|
    t.integer "aid", :null => false
    t.integer "eid", :null => false
	t.string "geventid", :default => "", :null => false
  end
  
  add_index "joinevents", ["aid"], :name => "aid"
  add_index "joinevents", ["eid"], :name => "event_id"
  
  create_table "tags", :primary_key => "tid", :force => true do |t|
  	t.string "tag",		:null => false
  end
  
# A relationship table
  create_table "event_tags", :id => false, :force => true do |t|
  	t.integer "tfid",	:null => false
  	t.integer "efid",	:null => false
  end

  add_index "event_tags", ["tfid"], :name => "tfid"
  add_index "event_tags", ["efid"], :name => "efid"

# Comment table

  create_table "comments", :primary_key => "cid", :force => true do |t|
    t.string   "commenter", :null => false
    t.string   "body",      :null => false
    t.datetime "timestamp", :null => false
    t.integer  "event_id",  :null => false
    t.integer  "aid",       :null => false
  end

  create_table "user_events", :primary_key => "ue_id", :force => true do |t|
    t.string 		  "recur_data", 		:null => false
    t.date        "recur_end",        	:null => false
    t.integer 		"eid",					:null => false
    t.integer		  "aid",					:null => false
  end
  
  add_index "user_events", ["eid"], :name => "eid"

end
