class Account < ActiveRecord::Base
	
	  set_primary_key :aid
	  
	  validates_confirmation_of :password
	  
  	  validates_presence_of :first_name, :last_name, :email, :password
end