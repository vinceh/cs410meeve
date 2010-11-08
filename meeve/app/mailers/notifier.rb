class Notifier < ActionMailer::Base
  default :from => "system@example.com"
  
  def forgot_password(recipient,password)
    @account = recipient
	@pass = password
	
    mail(:to => recipient.email, :subject => "Password Recovery")
  end
end