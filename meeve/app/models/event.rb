class Event < ActiveRecord::Base
  set_primary_key :event_id
  
  validates_presence_of :title, :desc, :location, :start_date, :end_date
  
  validate :valid_date?, :not_past?
 
  has_many :comments

  def valid_date?
    if Time.parse(end_date.to_s) <= Time.parse(start_date.to_s)
      errors.add(:event, ": Start date must be before end date.")
    end
  end  

  def not_past?
  	if Time.parse(end_date.to_s) < Time.parse(Time.now.to_s)
  		errors.add(:event, ": You can't create a passed event.")
  	end
  end
end
