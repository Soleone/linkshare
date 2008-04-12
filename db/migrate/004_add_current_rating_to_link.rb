class AddCurrentRatingToLink < ActiveRecord::Migration
  def self.up
    add_column :links, :current_rating, :integer
  end

  def self.down
    remove_column :links, :current_rating
  end
end
