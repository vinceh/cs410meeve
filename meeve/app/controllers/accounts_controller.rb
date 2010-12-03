require 'gcal4ruby'

class AccountsController < ApplicationController
  #before_filter :login_required_s, :except => [:new]
 
  
  def index
    @accounts = Account.all
  end

  
  def friend_profile
  	
  	if params[:aid] == session[:id].to_s
  		redirect_to :controller => :main, :action => :profile
  	else
  		flash[:error] = params[:aid] == session[:id]
	  	@user = Account.find(params[:aid])
	  	@events = find_all_events_to_view(params[:aid])
	  	@alrdy_follow = Follow.find_by_follower_and_followee(session[:id], @user.aid)
	  	
	  	@following = findAllFollowing(params[:aid])
	  	@followings = findAllFollowers(params[:aid])
  	end
  	
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
  	
  
  	@hits = Hash.new
  	@following = Follow.find_all_by_follower(session[:id])
  	
  	if @following == nil
  		flash[:error] = "No one to match your schedule to. You MUST be following someone first to use this function."
  	else
  		@following.each do |people| 
  			add = 1
  			@freefor = 18000
  			@freefor = @freefor.to_f
  			@timenow = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  			@events = Event.find_all_by_aid(people.followee)
  			@events.each do |eve|
				if (eve.start_date.to_s <= @timenow && @timenow < eve.end_date.to_s)
  					add = 0
  					break;
  				elsif (@timenow < eve.start_date.to_s)
  					if ((eve.start_date.to_time - @timenow.to_time) < @freefor)
  						@freefor = eve.start_date.to_time - @timenow.to_time
  					end
  				end
  			
  			end
  			if (add == 1)
  				@tempo = Account.find_by_aid(people.followee)
  			 	@hits.store(@tempo.first_name + " " + @tempo.last_name, @freefor.to_i )
  			end
  			
  		end
  		@hits.sort {|a,b| a[1] <=> b[1]}
  	end
  	
 end
 

  def new
    @account = Account.new
    
    if request.post?
      @account = Account.new(params[:account])
      @account.active = 1
      @account.facebook = 0

      if @account.save
      	####--------------- Calendar creation
      	service = GCal4Ruby::Service.new
		service.authenticate("meevecalendar@gmail.com", "jtantongco")
      	
      	calendar = GCal4Ruby::Calendar.new(service)
		
		calendar.summary = "This calendar was created on: " + Time.now.to_s
		calendar.public = true
      	calendar.save
		
		@account.gcal = calendar.id
		@account.save
		
		calendar.title = "User#" + @account.aid.to_s
		calendar.save
      	####--------------- End Calendar Creation
      	
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
  
  def view_calendar
	 	@account = Account.find(session[:id])
 		
		begin 
			@service = GCal4Ruby::Service.new
			@service.authenticate("meevecalendar@gmail.com", "jtantongco")		
			@calendar = GCal4Ruby::Calendar.find(
											@service,
											{:id => @account.gcal.to_s}
			)
			@Gcal = @calendar.to_iframe
			
		rescue
			@Gcal = "Your Google Calendar didn't authenticate properly. Please check your settings or contact support."
		end
  end
end