module SearchHelper
  # returns all links, that contain a certain text
  def search_for_links(text)
	  search_text = eval "/#{text}/i"
		Link.find(:all).select do |link|
			link.title =~ search_text ||
			link.url =~ search_text ||
			link.description =~ search_text
		end
  end
end
