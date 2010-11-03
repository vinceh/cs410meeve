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
  	t.string "login_name", :null => false
  	t.string "password", :null => false
  	t.string "first_name", :default => "", :null => false
  	t.string "last_name", :default => "", :null => false
  	t.boolean "active", :default => true, :null => false
  	t.string "email", :default => ""
  	t.string "phone_number", :default => ""
  	t.boolean "facebook", :default => false, :null => false
  end
  
# A relationship table
  create_table "follows", :id => false, :force => true do |t|
  	t.integer "follower", :null => false
  	t.integer "followee", :null => false
  end
  
  add_index "follows", ["follower"], :name => "follower"
  add_index "follows", ["followee"], :name => "followee"

  create_table "events", :primary_key => "eid", :force => true do |t|
    t.string    "pic"
    t.string    "desc",     :default => "", :null => false
    t.string    "location", :default => "", :null => false
    t.datetime  "start_date",               :null => false
    t.datetime  "end_date",                 :null => false
    t.integer   "flag"
  end
  
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
  
# A relationship table
  create_table "view_events", :id => false, :force => true do |t|
  	t.integer "efid",	:null => false
  	t.integer "afid",	:null => false
  end
  
  add_index "view_events", ["efid"], :name => "efid"
  add_index "view_events", ["afid"], :name => "afid"

  create_table "user_events", :primary_key => "ue_id", :force => true do |t|
    t.integer		"recur_type",  			:null => false
    t.integer 		"recur_interval", 		:null => false
    t.binary    	"recur_data",  			:null => false
    t.date          "recur_end",        	:null => false
    t.integer 		"eid",					:null => false
    t.integer		"aid",					:null => false
  end
  
  add_index "user_events", ["eid"], :name => "eid"

end
