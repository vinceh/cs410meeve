class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def hash (str)
    return Digest::SHA1.hexdigest(str)
  end
  
  def checkLogin
  	if session[:id]
  		redirect_to :action => :profile
  	end
  end
  
  def login_required
  	if !session[:id]
  		redirect_to :action => :index
  	end
  end
  
  #generates a random password consisting of strings and digits
  def random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end
