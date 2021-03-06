class CommentsController < ApplicationController

  before_filter :login_required

  def create

    if request.xhr?  
    	@comment = Comment.new(params[:comment])
      @comment.aid = session[:id]
        @comment.save
      render "comments/create"     
    else
      redirect_to :controller => :main, :action => :profile
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
      redirect_to :controller => :main, :action => :profile
    end    
  end

  # Show more comment if comments to be displayed are more than 5
  def show_more
  @event = Event.find(params[:eid])
    if request.xhr?
      @num = params[:num_of_comments].to_i
      @end_num = @num + 5
      if @event.comments.size-1 < @end_num
        @end_num = @event.comments.size - 1
      end

      render "comments/show_more"
    end 
  end

end
