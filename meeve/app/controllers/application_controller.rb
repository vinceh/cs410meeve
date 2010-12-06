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
  		redirect_to :controller => :main, :action => :index
  	end
  end
  
  #generates a random password consisting of strings and digits
  def random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
  def find_all_friends_events( id )
    @events = Event.find_all_by_aid_and_flag(id, 0)
    return @events.sort_by { |e| e['start_date'] }
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
  
   # When user creates an event, the user will automatically join the event.
   # this method will create the corresponding event in the currently logged in user's google calendar
   # this method for non-recurring events
   def join_event_save(eid)
    
    @event = Event.find(eid).event_id
    
    account = Account.find(session[:id])
    event = Event.find(@event)
    service = GCal4Ruby::Service.new
    service.authenticate("meevecalendar@gmail.com", "jtantongco")
    calendar = GCal4Ruby::Calendar.find(
                                        service,
                                        {:id => account.gcal})
    gevent = GCal4Ruby::Event.new(service, {  :calendar => calendar , 
                        :title => event.title,
                        :start_time => Time.parse(event.start_date.to_s), 
                        :end_time => Time.parse(event.end_date.to_s), 
                        :where => event.location})                
    
    join = Joinevent.new
    join.aid = session[:id]
    join.eid = @event
    gevent.save
    join.geventid = gevent.id
    e = Event.find(eid)
    e.gevent = gevent.id
    e.save
    join.save
  end
  
  # When user creates an event, the user will automatically join the event.
  # this method will create the corresponding event in the currently logged in user's google calendar
  # this method for recurring events
  def join_private_event_save(eid, array)
  	@event = Event.find(eid)
  	account = Account.find(session[:id])
  	service = GCal4Ruby::Service.new
    service.authenticate("meevecalendar@gmail.com", "jtantongco")
	calendar = GCal4Ruby::Calendar.find(
                                        service,
                                        {:id => account.gcal})
    gevent = GCal4Ruby::Event.new(service, { :calendar => calendar ,  
												:title => @event.title,
												:where => @event.location})
	gevent.recurrence = GCal4Ruby::Recurrence.new
	gevent.recurrence.start_time = Time.parse(@event.start_date.to_s)
	gevent.recurrence.end_time = Time.parse(@event.end_date.to_s)
	result = process_recurrence(array)
	gevent.recurrence.frequency = {"weekly" => result}
	gevent.save
	
	@event.gevent = gevent.id
	@event.save
	
	join = Joinevent.new
	join.aid = session[:id]
	join.eid = eid
	join.geventid = gevent.id
	join.save
  end
  
  #helper method that processes the input recurrence data from the view 
  # into the appropriate plug-in accepted format
  # Ex: recurring every sunday and saturday is represented from the view as: 1000001
  # plugin in will accept that as ["SU", "SA"]
  def process_recurrence(str)
  		result = Array.new
		if str[0] == 49
			result.push("SU")
		end
		if str[1] == 49
			result.push("MO")
		end
		if str[2] == 49
			result.push("TU")
		end
		if str[3] == 49
			result.push("WE")
		end
		if str[4] == 49
			result.push("TH")
		end
		if str[5] == 49
			result.push("FR")
		end
		if str[6] == 49
			result.push("SA")
		end
		return result
   end  
end
