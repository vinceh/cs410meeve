class AccountsController < ApplicationController
  #before_filter :login_required_s, :except => [:new]
 
  
  def index
    @accounts = Account.all
  end

  
  def friend_profile
  	@friend = Account.find(params[:aid])
  	@first_s = params[:search]
  	@second_s = params[:search_input]
  	
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
	  	
	  	
	  	#if request.xhr?
	  		render 'accounts/follow'
  		#else
	  	#	redirect_to :controller => :main, :action => :searching
  		#end
  	end
  	
  end
  
  def unfollow
  	
  		@fol = Follow.find_by_follower_and_followee(session[:id], params[:aid])
  		if @fol == nil
  			flash[:error] = "wtf????"
  		else
  			@sql = "DELETE FROM follows WHERE follower = "+@fol.follower.to_s+" AND followee = "+@fol.followee.to_s
      		ActiveRecord::Base.connection.execute(@sql)
      		
      		#if request.xhr?
      			render 'accounts/unfollow'
  			#else
  				#redirect_to :controller => :main, :action => :searching
  			#end
  		end
  		
  	  	
  end

  def matching
  	
  	@hits = Array.new
  	
  	@following = Follow.find_by_follower(session[:id])
  	if @following == nil
  		flash[:error] = "No one to match your schedule to. You MUST be following someone first to use this function."
  	else
  		@following.each do |people| 
  			@events = Event.find_by_user_id(people.followee)
  			@events.each do |eve|
  				if (!(@eve.start_date <= Time.now && Time.now < @eve.end_date))
  					@hits.push(Account.find_by_aid(people.followee))
  				end
  			end
  		end
  		
  	end
  	
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
        session[:id] = @account.aid
  		redirect_to :controller => :main, :action => :profile
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