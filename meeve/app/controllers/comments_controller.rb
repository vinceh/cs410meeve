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

end
