class EventsController < ApplicationController
  def index
    @events = Event.all
  end
  
  def new
    @event = Event.new
    
    if request.post?
      @event = Event.new(params[:event])
      
      if @event.save
        flash[:success] = "Your event has been successfully posted!"
        redirect_to(:action => :index)
      end
    end
  end
  
#  def create
#    @event = Event.create(params[:event])
#  end
  
  def edit
    @event = Event.find(params[:eid])
    
    if request.put?
      @event = Event.find(params[:eid])
      @event.update_attributes(params[:event])
      
      redirect_to(:action => "index")
    end
  end
  
  def remove
    @event = Event.find(params[:eid])
    
    if request.put?
      @event = Event.find(params[:eid])
      if (@event != nil)
        @event.destroy
        flash[:success] = "Your event has been successfully removed."
        redirect_to(:action => "index")
      end
    end
  end
  
  def show
    @event = Event.find(params[:eid])
    
    if request.xhr?
      render "events/show"
    else
      redirect_to :controller => :events
    end    
  end
end
