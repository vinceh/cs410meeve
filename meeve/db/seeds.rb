# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Event.create(:title => 'Party', :desc => 'Jake\'s BBQ', :location => 'UBC', :start_date => Time.now, :end_date => Time.now)