class EventsTable < ActiveRecord::Migration
   def self.up
    create_table :events, :primary_key => "eid", :force => true do |t|
      t.string	"pic"
      t.string 	"desc", 	:null => false
      t.string 	"location",	:null => false
      t.date 	"start", 	:null => false
      t.date 	"end", 		:null => false
      t.integer "flag"
    end
  end

  def self.down
    drop_table :events
  end
end
