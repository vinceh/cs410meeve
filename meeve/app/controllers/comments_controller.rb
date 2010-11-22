class CommentsController < ApplicationController

  def create
    if request.post?

        @user = Account.find(session[:id])
     end

    if request.xhr?  
    	@comment = Comment.new(params[:comment])
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
  
  def show_more
  @event = Event.find(params[:eid])
    if request.xhr?
      @num = params[:num_of_comments]
      render "comments/show_more"
    end 
  end

end
