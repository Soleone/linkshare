class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer   :value
      t.integer   :link_id, :references => 'links'
      t.string    :ip
      t.datetime  :created_at
    end
  end

  def self.down
    drop_table :ratings
  end
end
