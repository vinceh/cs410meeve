class Event < ActiveRecord::Base
  set_primary_key :eid
  
  validates_presence_of :desc, :location, :start_date, :end_date
  
  validate :valid_date?
  
  has_many :comments

  def valid_date?
    if Time.parse(end_date.to_s) < Time.parse(start_date.to_s)
      errors.add(:event, ": Start date must be before end date.")
    end
  end  
end
