# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def ajax_notice(text)
		content_tag('div', :id => 'notices') do
			textilize text
		end
	end
end
