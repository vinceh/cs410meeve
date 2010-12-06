require 'gcal4ruby'

class EventsController <  ApplicationController
  
  before_filter :login_required

  # Has no index redirect to main profile page
  def index
    redirect_to :controller => :main, :action => :profile
  end
  
  #Creates a new event
  #Creating an event automically signs you up as attending
  def new
    @event = Event.new
    #Sets the default start time to now and the default end time to be one hour from now
    @now = Time.now.year.to_s + "-" + Time.now.month.to_s + "-" + Time.now.day.to_s + " " + Time.now.hour.to_s + ":" + Time.now.min.to_s + ":00"
    nexthour = Time.now + 1.hours
    @later = Time.now.year.to_s + "-" + Time.now.month.to_s + "-" + Time.now.day.to_s + " " + nexthour.hour.to_s + ":" + Time.now.min.to_s + ":00"
    @start_dt = @now
    @end_dt = @later

    #After the user finishes the input
	if request.post?
	  #save the changes
      @event = Event.new(params[:event])
      @event.aid = session[:id]

      # Check if the event is private
      @user_event = nil;
      
      # Check if the event is reoccurring
      if params[:repeat_option]
        @user_event = User_event.new
      end
      
      #if the event has been saved
      if @event.save
      	#if the event is private, create an entry in the User_event table 
      	# and create a private recurring event in Gcal
        if @user_event != nil
          @user_event.recur_data = params[:repeat_option_binary_hidden]
          @user_event.recur_end = params[:repeat_option_end_dt_hidden]
          @user_event.eid = @event.event_id
          @user_event.aid = session[:id]
          if !(@user_event.save)
            #error_message
          end
          #public event creation helper defined in application controller	
          #joints the user to the event and creates the appropriate gcal event
          join_private_event_save(@event.event_id, @user_event.recur_data.to_s)
    	else
    	  #public event creation helper defined in application controller
    	  #joints the user to the event and creates the appropriate gcal event
    	  join_event_save(@event.event_id)
        end
        
        flash[:success] = "Your event has been successfully posted!"
        redirect_to :controller => :main, :action => :profile
      end
    end
  end
  
  def edit
    @event = Event.find(params[:eid])
    
    @start_dt = @event.start_date.year.to_s + "-" + @event.start_date.month.to_s + "-" + @event.start_date.day.to_s + " " + @event.start_date.hour.to_s + ":" + @event.start_date.min.to_s + ":00"
    @end_dt = @event.end_date.year.to_s + "-" + @event.end_date.month.to_s + "-" + @event.end_date.day.to_s + " " + @event.end_date.hour.to_s + ":" + @event.end_date.min.to_s + ":00"
    
    
    # if the event is private
    if @event.flag == 1
      @user_event = User_event.find_by_eid(params[:eid])
    end
    
    if request.put?   	
      	@event.update_attributes(params[:event])
        original_id = @event.gevent
        # If this is an user event, update the recurrsive table as well
        if @user_event != nil
          @user_event.update_attributes(:recur_data => params[:repeat_option_binary_hidden],
                                        :recur_end => params[:repeat_option_end_dt_hidden])
        end
        
        #authenticate the service, and find the currently logged in user's calendar
      	account = Account.find(session[:id])
      	service = GCal4Ruby::Service.new
      	service.authenticate("meevecalendar@gmail.com", "jtantongco")
      	calendar = GCal4Ruby::Calendar.find(
											service,
											{:id => account.gcal})
		#if a recurring event
		if @event.flag == 1
			#find the recurring event
	    	gevent = GCal4Ruby::Event.find(
	    									service, 
	    									{:id => @event.gevent})
			#update it's fields
			gevent.title = @event.title
			gevent.where = @event.location
			gevent.recurrence =  GCal4Ruby::Recurrence.new
			gevent.recurrence.start_time = Time.parse(@event.start_date.to_s)
			gevent.recurrence.end_time = Time.parse(@event.end_date.to_s)
			
			#process the recurrence schedule into one that the gcal plugin will accept
			#helper method defined in application controller
			result = process_recurrence(@user_event.recur_data.to_s)
			gevent.recurrence.frequency = {"weekly" => result}
			
			#save the changes
			gevent.save
		end	
		#if not a recurring event				
    	if @event.flag == 0
    		#gcal plugin treats edits as deletes when a non-recurring event is saved
	    	#therefore find the old event and 'delete' it then create a new event and update the event gevent id
	    	
	    	#find the old event
	    	gevent = GCal4Ruby::Event.find(
	    										service, 
	    										{:id => @event.gevent})
		    #mark it as non-useful/deleted
		    gevent.title = "Deleted"
		    gevent.start_time = Time.parse("31-01-2000 at 12:30 PM")
		    gevent.end_time = Time.parse("31-01-2000 at 12:31 PM")
		    gevent.where = "Deleted"
		    
		    #commit the changes
			gevent.save
	    	
	    	#start of the weird stuff
	    	#create a new event with the edited fields
	    	newgevent = GCal4Ruby::Event.new(service, {:calendar => calendar, 
												 	:title => @event.title.to_s,
													:start_time => Time.parse(@event.start_date.to_s), 
													:end_time => Time.parse(@event.end_date.to_s), 
													:where => @event.location})
	    	#commit the new gevent to gcal
	    	#note that this has to be done before @event.save because gevent.id is nil
	    	#until it is saved to gcal
	    	newgevent.save
	    	@event.gevent = newgevent.id
	    	#save the event into our database
	    	@event.save
    	
    		#find all the people that joined your event
    		@joined = Joinevent.find(:all, :conditions => {:eid => @event.event_id})
		
			@joined.each{ |j|
			    #conditional checks if this is the record of your joining your own event
			    #this is stop two of the same event from being created in your calendar
				if !(original_id == j.geventid)
					#find the joiner's account info
					joiner = Account.find(j.aid)
					#find the joiner's calendar
					cal = GCal4Ruby::Calendar.find(
												service, 
												{:id => joiner.gcal})
					#erase the existing event (as edits are treated as deletes)    	
					gev = GCal4Ruby::Event.find(
													service, 
													{:id => j.geventid})
					gev.title = "Deleted"
					gev.start_time = Time.parse("31-01-2000 at 12:30 PM")
					gev.end_time = Time.parse("31-01-2000 at 12:31 PM")
					gev.where = "Deleted"
					gev.save
					
					#create a new event with the updated details in the joiner's calendar
					newgevent = GCal4Ruby::Event.new(service, {:calendar => cal, 
													 	:title => @event.title,
														:start_time => @event.start_date, 
														:end_time => @event.end_date, 
														:where => @event.location})
					newgevent.save
					#save the new gevent id to the Joinevent table
					j.geventid = newgevent.id
					j.save
				else
					#save the new geventid to your joiner tuple
					j.geventid = newgevent.id
					j.save
				end				
			}
		end
		#redirect to the main controller page
      	redirect_to :controller => :main, :action => :profile
    end
  end
  
  def remove
    @event = Event.find(params[:eid])
    
    # If the event is private
    if @event.flag == 1
      @user_event = User_event.find_by_eid(params[:eid])
    end
    
    if (@event != nil)
      # remove all attached comments
      @event.comments.each do |c|
        c.destroy
      end
      account = Account.find(session[:id])
      
      service = GCal4Ruby::Service.new
      service.authenticate("meevecalendar@gmail.com", "jtantongco")
      #if not a recurring event
      if @event.flag == 0
      	  #find the user's calendar and the event being deleted
	      calendar = GCal4Ruby::Calendar.find(
	                                          service,
	                                          {:id => account.gcal})
	      gevent = GCal4Ruby::Event.find(
	                                     service, 
	                                     {:id => @event.gevent})
	      
	      #no delete method in gem, .destroy doesn't seem to work
	      #results from trying to move the event to a trash calendar are in-conclusive 
	      #gevent[0].calendar = trash_cal
	      #settled on moving deleted events to January 31, 2000, at 12:30 pm to 12:31 pm
	      #'delete' the google calendar event
	      gevent.title = "Deleted"
	      gevent.start_time = Time.parse("31-01-2000 at 12:30 PM")
	      gevent.end_time = Time.parse("31-01-2000 at 12:31 PM")
	      gevent.where = "Deleted"
	      gevent.save
	      
	      #find all the tuples that makr people as joining the event to be deleted
	      @joined = Joinevent.find(:all, :conditions => {:eid => @event.event_id})
	      #foe each person that has joined
		  @joined.each{ |j|
				joiner = Account.find(j.aid)
				cal = GCal4Ruby::Calendar.find(
												service, 
												{:id => joiner.gcal})
				#edit/erase the existing event    	
				gev = GCal4Ruby::Event.find(
												service, 
												{:id => j.geventid})
				gev.title = "Deleted"
				gev.start_time = Time.parse("31-01-2000 at 12:30 PM")
				gev.end_time = Time.parse("31-01-2000 at 12:31 PM")
				gev.where = "Deleted"
	
				gev.save
				
				#destroy the tuple from the Joinevet table
				j.destroy
			}
  	  end
  	  
  	  #if the event is recurring, move it to a specifically designated trash calendar within the system
  	  if @event.flag == 1
  	  	trash_cal = GCal4Ruby::Calendar.find(
      									service,
      									{:id => "rthd8o1h5ron9n3kth1bj3d4is@group.calendar.google.com"})
  	  	gevent = GCal4Ruby::Event.find(
                                     	service, 
                                     	{:id => @event.gevent})
        gevent.calendar = trash_cal
        gevent.recurrence =  GCal4Ruby::Recurrence.new
		gevent.recurrence.start_time = Time.parse("31-01-2000 at 12:30 PM")
		gevent.recurrence.end_time = Time.parse("31-01-2000 at 12:31 PM")
		gevent.recurrence.frequency = {"weekly" => ["SA"]}
        gevent.save
        #find all people who have joined this event
        #theoretically this should only be the user since all recurring events are private events
        @joined = Joinevent.find(:all, :conditions => {:eid => @event.event_id})
	  	@joined.each{ |j|
	  		#destroy that tuple
	  		j.destroy
  		}
  	  end
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
      #creates the event they joined in the user's google calendar
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
      
      #marks them as Joined to the event in the Joinevent table
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
      #find the user's tuple in the Joinevent table
      @joined_event = Joinevent.find_by_aid_and_eid(session[:id], params[:eid])
      if (@joined_event != nil)
      	  #finds the google calendar event and 'deletes' it
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
		  #destroys the user's joinevent tuple from the database
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