class AccountsController < ApplicationController
  #before_filter :login_required_s, :except => [:new]
 
  
  def index
    @accounts = Account.all
  end
  
  def show

	@accts = Account.all
	@acct = Account.find(session[:id])
	@accts.delete(@acct)
   
  end
  
  def friend_profile
  	@friend = Account.find(params[:aid])
  	
  	@alrdy_follow = Follow.find_by_follower_and_followee(session[:id], @friend.aid)
  	
  end
  
  def follow
  	
  	
  	@follow = Follow.new
  	@follow.follower = session[:id]
  	@follow.followee = params[:aid]
  	if @follow.save
	  	#@follow.update_attribute(:follower, session[:id])
	  	#@follow.update_attribute(:followee, params[:aid])
	  	@fol_name = Account.find(params[:aid])
	  	flash[:success] = "You are now following" + @fol_name.first_name + " " + @fol_name.last_name + "."
	  	redirect_to :action => :show
  	end
  	
  end
  
  def unfollow
  	
  		@fol = Follow.find_by_follower_and_followee(session[:id], params[:aid])
  		if @fol != nil
  			@fol.destroy
  		end
  		
  		redirect_to :action => :friend_profile, :aid => params[:aid]
  	
  end

  def new
    @account = Account.new
    
    if request.post?
      @account = Account.new(params[:account])
      @account.active = 1
      @account.facebook = 0

      if @account.save
      	
      	@account.update_attribute(:password, hash(@account.password))
        # @account.update_attribute(params[:account])  
        flash[:success] = "Your account has been successfully created!"
        redirect_to :controller => :main, :action => :index
      end
    end
  end
  
  def edit
    @account = Account.find(session[:id])
    
    if request.put?
    	@account = Account.find(params[:aid])
    	@account.update_attributes(params[:account])
		flash[:success] = 'Account was successfully updated.'
    	redirect_to :controller => :main, :action => :index  
    end
  end
 
end