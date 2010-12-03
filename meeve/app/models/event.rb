class Event < ActiveRecord::Base
  set_primary_key :event_id
  
  validates_presence_of :title, :desc, :location, :start_date, :end_date
  
  validate :valid_date?, :not_past?, :right_length?
 
  has_many :comments

  def valid_date?
    if Time.parse(end_date.to_s) <= Time.parse(start_date.to_s)
      errors.add(:end_date, " must be greater than the start date.")
    end
  end  

  def not_past?
  	if Time.parse(end_date.to_s) < Time.parse(Time.now.to_s)
  		errors.add(:start_date, "You can't create a passed event.")
  	end
 end
 
 def right_length?
   if desc.length > 140
     errors.add(:desc, " length should be less than 140 characters.")
   end
 end

#  def not_0durationevent?
#    if Time.parse(end_date.to_s) == Time.parse(start_date.to_s)
#      errors.add(:event, ": Start date cannot be the same as end date.")
#    end
#  end
end
