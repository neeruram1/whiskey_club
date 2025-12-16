class AddCounterCaches < ActiveRecord::Migration[7.1]
  def change
    add_column :bottles, :ratings_count, :integer, default: 0, null: false
    add_column :meetings, :attendees_count, :integer, default: 0, null: false
    
    # Backfill counter caches
    reversible do |dir|
      dir.up do
        Bottle.find_each do |bottle|
          Bottle.reset_counters(bottle.id, :ratings)
        end
        
        Meeting.find_each do |meeting|
          Meeting.reset_counters(meeting.id, :meeting_attendees)
        end
      end
    end
  end
end
