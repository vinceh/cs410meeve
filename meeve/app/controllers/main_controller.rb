class MainController < ApplicationController
	
  before_filter :login_required, :except => [:index, :recover_password]
  before_filter :checkLogin, :only => [:index]
  
  def index
  	if request.post?
  		user = Account.find_by_email(params[:account][:email])
  		
  		if user != nil
  			
  			if user.password == hash(params[:account][:password])
  				redirect_to :action => :profile
  				session[:id] = user.aid
  			else
  				flash[:error] = "Invalid login	"
  				redirect_to :action => :index, :email => params[:account][:email]
  			end
  		else
  			flash[:error] = "Invalid login"
  			redirect_to :action => :index, :email => params[:account][:email]
  		end
  	end
  end
  
  def recover_password
  	if request.post?
      user = Account.find_by_email(params[:user][:email])
      if user == nil
        flash.now[:error] = "User does not exist"
      else
        new_pass = random_string(10)
        user.password = hash(new_pass)
        user.save
        Notifier.forgot_password(user, new_pass).deliver
        flash[:success] = "An email has been sent to your email address, please follow the instructions.  If you do not find it in your inbox, please check your spam folders."
        redirect_to :action => :index
      end
    end
  end
  
  def profile
  end
  
  def change_password
  	@account = Account.find(session[:id])
  	
	if request.put?
	  old_password = params[:old_password]
	  new_password = params[:password]
	  confirm_password = params[:password_confirmation]
	  if @account.password == hash(old_password)
	    if new_password.length > 0 && new_password == confirm_password
	      @account.update_attribute("password", hash(new_password))
	      flash[:success] = 'Your password has been changed.'
	      redirect_to :controller => :accounts, :action => :edit
	    else
	      @account.errors.add "New password", "and confirmation password do not match."
	    end
	  else
	    @account.errors.add "Old password", "is invalid"
      end
	end
  end
  
  def logout
  	session[:id] = nil
  	redirect_to :action => :index
  end
end
