class AddIndexesToOptimizeQueries < ActiveRecord::Migration[7.1]
  def change
    # Bottles table indexes
    add_index :bottles, :meeting_id unless index_exists?(:bottles, :meeting_id)
    add_index :bottles, :user_id unless index_exists?(:bottles, :user_id)
    
    # Ratings table indexes
    add_index :ratings, :bottle_id unless index_exists?(:ratings, :bottle_id)
    add_index :ratings, :user_id unless index_exists?(:ratings, :user_id)
    add_index :ratings, [:user_id, :bottle_id], unique: true unless index_exists?(:ratings, [:user_id, :bottle_id])
    
    # Meetings table indexes
    add_index :meetings, :date unless index_exists?(:meetings, :date)
    add_index :meetings, :bottle_bringer_id unless index_exists?(:meetings, :bottle_bringer_id)
    
    # Meeting attendees indexes
    add_index :meeting_attendees, :meeting_id unless index_exists?(:meeting_attendees, :meeting_id)
    add_index :meeting_attendees, :user_id unless index_exists?(:meeting_attendees, :user_id)
    add_index :meeting_attendees, [:meeting_id, :user_id], unique: true unless index_exists?(:meeting_attendees, [:meeting_id, :user_id])
  end
end
