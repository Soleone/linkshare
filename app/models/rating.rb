class Rating < ActiveRecord::Base
  belongs_to :link
  
  validates_inclusion_of  :value, 
                          :in => 0..3, 
                          :message => "must be between 0 and 3"
end
