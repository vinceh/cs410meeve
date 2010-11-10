class CommentsController < ApplicationController

  def create
    if request.post?
        @event = Event.find(params[:event_id])
        @comment = @event.comments.create(params[:comment])
     end

    if request.xhr?  
      render "comments/create"     
    else
      redirect_to :controller => :events
    end
  end

  def remove
    @comment = Comment.find(params[:cid])
    if @comment != nil
      @comment.destroy
    end
    
    if request.xhr?
      render "comments/remove"
    else
      redirect_to :controller => :events
    end    
  end

end
