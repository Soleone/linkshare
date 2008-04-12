# user is not supported at this stage
class AddActsAsCommentable < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.string  :title, :limit => 50, :default => ""
      t.text    :text
      t.integer :commentable_id, :default => 0, :null => false
      t.string  :commentable_type, :limit => 15, :default => "", :null => false
      t.timestamps
    end
  end
  
  def self.down
    drop_table :comments
  end
end
