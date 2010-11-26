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
	
#	@service = GCal4Ruby::Service.new
#	#TODO: ideal way of setting up google calendar + where gcal password is stored
#	#Note if you want to visit this page, temporarily put in your gmail or something cause this will cause an error. 
#	if @service.authenticate("jtantongco@gmail.com", "")		
#		@Gcal = @service.to_iframe(:all)
#	else
#		#failure to authenticate throws error
#		#TODO: Need to catch error and inform user to de-link google calendar
#		@Gcal = "Your Google Calendar didn't authenticate properly. Please check your settings."
#	end
#	
#	@calendars = GCal4Ruby::Calendar.new(@service)
	
	if request.post?
      @event = Event.new(params[:event])
      @event.aid = session[:id]
      
      if @event.save
        flash[:success] = "Your event has been successfully posted!"
        redirect_to :controller => :main, :action => :profile
      end
    end
  end
  
  def edit
    @event = Event.find(params[:eid])
    
    @start_dt = @event.start_date
    @end_dt = @event.end_date
    
    if request.put?   
      @event.update_attributes(params[:event])
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
end