class SearchController < ApplicationController
	include SearchHelper
	
	def index
  	text = params[:text]
  	@links = search_for_links(text)
  	@highlight = text
		render :template => 'links/index', :locals => {:highlight_text => text}
	end
	
	def suggest
		text = params[:text]
		search_text = Regexp.new "/#{text}/i"
		links = Link.find(:all).select do |link|
			link.title =~ search_text
		end
		render :text => links.join(',')
	end
end
