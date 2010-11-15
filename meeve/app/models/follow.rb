class Follow < ActiveRecord::Base
	belongs_to :account
	

  validates_presence_of :follower, :followee
end