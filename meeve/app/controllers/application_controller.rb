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
  
  def find_all_events_to_view( id )
    
    @events = Array.new
    
    @followees = findAllFollowing(id)
    @followees.each do |f|
      @followee_events = Event.find_all_by_aid_and_flag(f.aid, 0)
      @followee_events.each do |e|
        if e != nil && Time.now < e.end_date && Time.now.yday == e.start_date.yday
          @events.push(e)
        end
      end
    end
 
    @my_events = Event.find_all_by_aid(id)
    @my_events.each do |e|
      if e != nil && Time.now.utc < e.end_date
        @events.push(e)  
      end      
    end
    
    return @events.sort_by { |e| e['start_date'] }
  end
  
  def findAllFollowing( id )
  	follow = Follow.find_all_by_follower(id)
  	returnee = Array.new
  	follow.each { |f|
  		returnee.push(Account.find(f.followee))
  	}
  	return returnee
  end
  
  def findAllFollowers( id )
  	follows = Follow.find_all_by_followee(id)
  	returnees = Array.new
  	follows.each { |f|
  		returnees.push(Account.find(f.follower))
  	}
  	return returnees
  end
end
