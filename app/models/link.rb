class Link < ActiveRecord::Base
  
  has_many  :ratings
  acts_as_commentable
  
  before_validation :check_url
  before_save :calculate_rating
  
  validates_presence_of   :title, :url, :description
  validates_uniqueness_of :title, :url
  validates_length_of     :title, 
                          :maximum => 40

	include LinksHelper
	
	def to_param
    "#{id}-#{title.gsub(/[^a-z1-9]+/i, '-')}"
  end
    
  # validates that the URL is valid
  def validate
	  #unless link_is_existent?(url)
	  #  errors.add(:url, :invalid_url.l)
	  #end
	end

  def has_been_rated_by(ip)
  	Rating.find(:first, :conditions => ["link_id = ? && ip = ?", id, ip])
  end
  
    
  def add_comment(title, text)
		new_comment = Comment.new(:title => title, :text => text)
    self.comments << new_comment
    if self.save
      notice = "Saved your comment for this Link!"
    else
      notice = "Could not save the comment for this link!"
    end
  end
  
  
  protected
  # check that url starts with http://
  def check_url
    self.url.insert(0, 'http://') unless self.url =~ Regexp.new('http://')
  end
  
  # updates the attribute 'current_rating' by calculating the average of all ratings for this Link
  def calculate_rating
    puts "Calculating rating for this Link."
    if ratings.empty?
      my_rating = 0
    else
      total = 0
      ratings.each do |rating|
        total += rating.value
      end
       # calculate average
      my_rating = (total.to_f / ratings.count).round        
    end
    self.current_rating = my_rating
  end
end
