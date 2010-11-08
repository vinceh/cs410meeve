class CommentController < ApplicationController
  def new
    @event = Event.find(params[:eid])
    @comment = @event.comments.create(params[:comment])
    redirect_to(:action => "events/index")
    
  end

  def remove
  end

end
