class EventsController < ApplicationController
  def index
    redirect_to :controller => :main, :action => :profile
  end
  
  def new
    @event = Event.new
    @datetime = Time.now.year.to_s + "-" + Time.now.month.to_s + "-" + Time.now.day.to_s + " " + Time.now.hour.to_s + ":" + Time.now.min.to_s + ":00"
    
    if request.post?
      @event = Event.new(params[:event])
      
      if @event.save
        flash[:success] = "Your event has been successfully posted!"
        redirect_to :controller => :main, :action => :profile
      end
    end
  end
  
#  def create
#    @event = Event.create(params[:event])
#  end
  
  def edit
    @event = Event.find(params[:eid])
    if request.put?   
      @event.update_attributes(params[:event])
      redirect_to :controller => :main, :action => :profile
    end
  end
  
  def destroy
    @event = Event.find(params[:eid])
    
    if request.post?
      @event = Event.find(params[:eid])
      if (@event != nil)
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