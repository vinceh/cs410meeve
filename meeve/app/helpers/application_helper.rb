module ApplicationHelper
	
	def required
		content_tag(:span, " *", :class => "manditory")
	end
end
