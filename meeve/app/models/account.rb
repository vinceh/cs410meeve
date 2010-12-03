class Account < ActiveRecord::Base
	
	  set_primary_key :aid
	  
	  validates_uniqueness_of :email
	  
	  validates_confirmation_of :password
	  
  	  validates_presence_of :first_name, :last_name, :email, :password
  	  
  	  validate :password_strength, :email_valid
  	  
  	  def password_strength
  	  	
  	  	if password.length < 6
  	  		errors.add(:password, " not 6 characters")
  	  	end
  	  end
  	  
  	  def email_valid
  	  	
  	  	if !(email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
  	  		errors.add(:email, " is not a valid email")
  	  	end
  	  end
end