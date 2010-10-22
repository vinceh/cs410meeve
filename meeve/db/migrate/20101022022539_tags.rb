class Tags < ActiveRecord::Migration
  def self.up
  	create_table "tags", :primary_key => "tid", :force => true do |t|
  		t.string "name"
  	end  		
  end

  def self.down
  end
end
