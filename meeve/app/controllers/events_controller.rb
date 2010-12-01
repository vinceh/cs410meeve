require 'gcal4ruby'

class EventsController <  ApplicationController
  
  def index
    redirect_to :controller => :main, :action => :profile
  end
  
  def new
    @event = Event.new
    @now = Time.now.year.to_s + "-" + Time.now.month.to_s + "-" + Time.now.day.to_s + " " + Time.now.hour.to_s + ":" + Time.now.min.to_s + ":00"
        
    @start_dt = @now
    @end_dt = @now

	@Gcal = "Comment this out."
	
	if request.post?
      @event = Event.new(params[:event])
      @event.aid = session[:id]
      
      account = Account.find(session[:id])
      
      service = GCal4Ruby::Service.new
      service.authenticate("meevecalendar@gmail.com", "jtantongco")
	  calendar = GCal4Ruby::Calendar.find(
											service,
											{:id => account.gcal})
      gevent = GCal4Ruby::Event.new(service, { 	:calendar => calendar , 
											 	:title => @event.title,
												:start_time => @event.start_date, 
												:end_time => @event.end_date, 
												:where => @event.location}) 	
      if @event.save
      	gevent.save
      	#gevent.id is empty string, until the event is committed to google calendar
      	@event.gevent = gevent.id
      	@event.save
        flash[:success] = "Your event has been successfully posted!"
        redirect_to :controller => :main, :action => :profile
      end
    end
  end
  
  def edit
    @event = Event.find(params[:eid])
    original_title = @event.title
    @start_dt = @event.start_date
    @end_dt = @event.end_date
    
    if request.put?   	
      	@event.update_attributes(params[:event])
      
      	account = Account.find(session[:id])
      
      	service = GCal4Ruby::Service.new
      	service.authenticate("meevecalendar@gmail.com", "jtantongco")
	  	calendar = GCal4Ruby::Calendar.find(
											service,
											{:id => account.gcal})
		gevent = GCal4Ruby::Event.find(
										service, 
										{:id => @event.gevent})
		gevent.title = @event.title
		gevent.start_time = @event.start_date
		gevent.end_time = @event.end_date
		gevent.where = @event.location
		gevent.save
		
      	redirect_to :controller => :main, :action => :profile
    end
  end
  
  def remove
    @event = Event.find(params[:eid])
    
    if request.put?
      @event = Event.find(params[:eid])
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
		@event.destroy
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
      
      @join = Joinevent.new
      @join.aid = @account
      @join.eid = @event
      
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
      @je = Joinevent.find(@joined_event.jeid)
      
      if (@je != nil)
          @je.destroy
          render "events/quit_event"
      end
    else
      redirect_to(:controller => :main, :action => :profile)
    end
  end
end