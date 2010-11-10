class Comment < ActiveRecord::Base
  set_primary_key :cid
  
  belongs_to :event
end
