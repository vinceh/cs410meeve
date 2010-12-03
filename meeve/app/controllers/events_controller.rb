require 'gcal4ruby'

class EventsController <  ApplicationController
  
  def index
    redirect_to :controller => :main, :action => :profile
  end
  
  def new
    @event = Event.new
    @now = Time.now.year.to_s + "-" + Time.now.month.to_s + "-" + Time.now.day.to_s + " " + Time.now.hour.to_s + ":" + Time.now.min.to_s + ":00"
    nexthour = Time.now + 1.hours
    @later = Time.now.year.to_s + "-" + Time.now.month.to_s + "-" + Time.now.day.to_s + " " + nexthour.hour.to_s + ":" + Time.now.min.to_s + ":00"
        
    @start_dt = @now
    @end_dt = @later
    
	if request.post?
      @event = Event.new(params[:event])
      @event.aid = session[:id]
      
      account = Account.find(session[:id])
      
      # Google calendar stuff
      service = GCal4Ruby::Service.new
      service.authenticate("meevecalendar@gmail.com", "jtantongco")
	  calendar = GCal4Ruby::Calendar.find(
											service, 
											{:id => account.gcal})
      gevent = GCal4Ruby::Event.new(service, { 	:calendar => calendar , 
											 	:title => @event.title,
												:start_time => Time.parse(@event.start_date.to_s), 
												:end_time => Time.parse(@event.end_date.to_s), 
												:where => @event.location})
                        
      # Check if the event is private
      @user_event = nil;
      
      if params[:repeat_option]
        @user_event = User_event.new
      end
      
      gevent.save
      #gevent.id is empty string, until the event is committed to google calendar
      @event.gevent = gevent.id
      
      if @event.save

        if @user_event != nil
          @user_event.recur_data = params[:repeat_option_binary_hidden]
          @user_event.recur_end = params[:repeat_option_end_dt_hidden]
          @user_event.eid = @event.event_id
          @user_event.aid = session[:id]
          if !(@user_event.save)
            #error_message
          end
        end
        
        join_event_save(@event.event_id)
        
        flash[:success] = "Your event has been successfully posted!"
        redirect_to :controller => :main, :action => :profile
      end
    end
  end
  
  def edit
    @event = Event.find(params[:eid])
    original_title = @event.title
    
    @start_dt = @event.start_date.year.to_s + "-" + @event.start_date.month.to_s + "-" + @event.start_date.day.to_s + " " + @event.start_date.hour.to_s + ":" + @event.start_date.min.to_s + ":00"
    @end_dt = @event.end_date.year.to_s + "-" + @event.end_date.month.to_s + "-" + @event.end_date.day.to_s + " " + @event.end_date.hour.to_s + ":" + @event.end_date.min.to_s + ":00"
    
    
    # if the event is private
    if @event.flag = 1
      @user_event = User_event.find_by_eid(params[:eid])
    end
    
    if request.put?   	
      	@event.update_attributes(params[:event])
        
        # If this is an user event, update the recurrsive table as well
        if @user_event != nil
          @user_event.update_attributes(:recur_data => params[:repeat_option_binary_hidden],
                                        :recur_end => params[:repeat_option_end_dt_hidden])
        end
      
      	account = Account.find(session[:id])
      
      	service = GCal4Ruby::Service.new
      	service.authenticate("meevecalendar@gmail.com", "jtantongco")
      	
      	calendar = GCal4Ruby::Calendar.find(
											service,
											{:id => account.gcal})
    	
    	#delete/edit the old one
    	gevent = GCal4Ruby::Event.find(
    										service, 
    										{:id => @event.gevent})
	    gevent.title = "Deleted"
	    gevent.start_time = Time.parse("31-01-2000 at 12:30 PM")
	    gevent.end_time = Time.parse("31-01-2000 at 12:31 PM")
	    gevent.where = "Deleted"
		gevent.save
    	
#    	gevent.title = @event.title
#    	gevent.start_time = @event.start_date
#    	gevent.end_time = @event.end_date
#    	gevent.where = @event.location

    	#start of the weird stuff
    	#create a new copy
    	newgevent = GCal4Ruby::Event.new(service, {:calendar => calendar, 
											 	:title => @event.title.to_s,
												:start_time => Time.parse(@event.start_date.to_s), 
												:end_time => Time.parse(@event.end_date.to_s), 
												:where => @event.location})
    	newgevent.save
    	@event.gevent = newgevent.id
    	@event.save
    	
    	@joined = Joinevent.find(:all, :conditions => {:eid => @event.event_id})
		
		@joined.each{ |j|
			joiner = Account.find(j.aid)
			cal = GCal4Ruby::Calendar.find(
											service, 
											{:id => joiner.gcal})
			#edit/erase the existing event    	
			gev = GCal4Ruby::Event.find(
											service, 
											{:id => j.geventid})
#			gev.title = @event.title
#			gev.start_time = @event.start_date
#			gev.end_time = @event.end_date
#			gev.where = @event.location
			gev.title = "Deleted"
			gev.start_time = Time.parse("31-01-2000 at 12:30 PM")
			gev.end_time = Time.parse("31-01-2000 at 12:31 PM")
			gev.where = "Deleted"

			gev.save
			#end edit
			
			#create a new event with the updated details in the joiner's calendar
			newgevent = GCal4Ruby::Event.new(service, {:calendar => cal, 
											 	:title => @event.title,
												:start_time => @event.start_date, 
												:end_time => @event.end_date, 
												:where => @event.location})
			newgevent.save
			j.geventid = newgevent.id
			j.save				
		}
    	#end of the weird stuff
      	redirect_to :controller => :main, :action => :profile
    end
  end
  
  def remove
    
    @event = Event.find(params[:eid])
    
    # If the event is private
    if @event.flag = 1
      @user_event = User_event.find_by_eid(params[:eid])
    end
    
    if (@event != nil)
      @event.comments.each do |c|
        c.destroy
      end
     
      account = Account.find(session[:id])
      
      service = GCal4Ruby::Service.new
      service.authenticate("meevecalendar@gmail.com", "jtantongco")
      calendar = GCal4Ruby::Calendar.find(
                                          service,
                                          {:id => account.gcal})
      #trash_cal = GCal4Ruby::Calendar.find(
      #									service,
      #									{:id => "6h9ukoe7qac2aabimv18lk19k4@group.calendar.google.com"})
      gevent = GCal4Ruby::Event.find(
                                     service, 
                                     {:id => @event.gevent})
      
      #no delete method in gem, .destroy doesn't seem to work
      #results from trying to move the event to a trash calendar are in-conclusive 
      #gevent[0].calendar = trash_cal
      #settled on moving deleted events to January 31, 2000, at 12:30 pm to 12:31 pm
      gevent.title = "Deleted"
      gevent.start_time = Time.parse("31-01-2000 at 12:30 PM")
      gevent.end_time = Time.parse("31-01-2000 at 12:31 PM")
      gevent.where = "Deleted"
      gevent.save
      if @event.destroy
        
        if @user_event != nil
          @user_event.destroy
        end
        flash[:success] = "Your event has been successfully removed."
        redirect_to :controller => :main, :action => :profile
      end
    end
    
  end
  
  def show_event
    
    @user = Account.find(session[:id])
    @event = Event.find(params[:eid])
    @comment = Comment.new
    
    if request.xhr?
      render "events/show_event"
    else
      redirect_to(:controller => :main, :action => :profile)
    end    
  end
  
  def join_event
    
    @account = session[:id]
    @event = Event.find(params[:eid]).event_id
    
    if request.xhr?
      account = Account.find(session[:id])
      event = Event.find(@event)
      service = GCal4Ruby::Service.new
      service.authenticate("meevecalendar@gmail.com", "jtantongco")
      calendar = GCal4Ruby::Calendar.find(
                                          service,
                                          {:id => account.gcal})
      gevent = GCal4Ruby::Event.new(service, { 	:calendar => calendar , 
											 	:title => event.title,
												:start_time => Time.parse(event.start_date.to_s), 
												:end_time => Time.parse(event.end_date.to_s), 
												:where => event.location}) 								
      
      @join = Joinevent.new
      @join.aid = @account
      @join.eid = @event
      gevent.save
      @join.geventid = gevent.id
      
      if @join.save
        render "events/join_event"
      end
    else
      redirect_to(:controller => :main, :action => :profile)
    end
  end
  
  def quit_event
    
    @event = Event.find(params[:eid]).event_id
    
    if request.xhr?
      
      @joined_event = Joinevent.find_by_aid_and_eid(session[:id], params[:eid])

      if (@joined_event != nil)
	      account = Account.find(session[:id])
	      service = GCal4Ruby::Service.new
	      service.authenticate("meevecalendar@gmail.com", "jtantongco")
		  gevent = GCal4Ruby::Event.find(
										service, 
										{:id => @joined_event.geventid})
		  gevent.title = "Deleted"
		  gevent.start_time = Time.parse("31-01-2000 at 12:30 PM")
		  gevent.end_time = Time.parse("31-01-2000 at 12:31 PM")
		  gevent.where = "Deleted"
		  gevent.save
          @joined_event.destroy
          render "events/quit_event"
      end
    else
      redirect_to(:controller => :main, :action => :profile)
    end
  end
  
  def repeat_event
    
  end
  
  def set_repeat
    
  end
end