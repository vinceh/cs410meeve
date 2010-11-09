class CommentsController < ApplicationController

  def create
    if request.post?
        @event = Event.find(params[:event_id])
        @comment = @event.comments.create(params[:comment])
        redirect_to :controller => :events 
    end
  end

  def remove
    @comment = Comment.find(params[:cid])
    if @comment != nil
      @comment.destroy
      redirect_to :controller => :events
    end
    
  end

end
