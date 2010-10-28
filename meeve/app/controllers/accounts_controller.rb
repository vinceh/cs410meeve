class AccountsController < ApplicationController
  #before_filter :login_required_s, :except => [:new]
 
  
  def index
    @accounts = Account.all
  end
  def show
    @account = Account.find(params[:aid])
  end

  def new
    @account = Account.new
 
    
    if request.post?
      @account = Account.new(params[:account])
      @account.active = 1
      @account.facebook = 0

      if @account.save
        @account.update_attribute(params[:account])  
        flash[:success] = "Your account has been successfully created!"
        redirect_to :action => :index
      
  
      end
    end
  end
  
 
  
  def edit
    @account = Account.find(params[:aid])
    
    if request.post? && @account.update_attributes(params[:account])
      flash[:success] = 'Account was successfully updated.'
      redirect_to :action => :index
    end
  end

  
 
end