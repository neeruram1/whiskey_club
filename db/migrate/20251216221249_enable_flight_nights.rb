class EnableFlightNights < ActiveRecord::Migration[7.1]
  def up
    # Remove unique constraint on bottles.meeting_id to allow multiple bottles per meeting
    if index_exists?(:bottles, :meeting_id, name: "index_bottles_on_meeting_id_unique_when_present")
      remove_index :bottles, name: "index_bottles_on_meeting_id_unique_when_present"
    end
    
    # Add regular index for bottles.meeting_id
    add_index :bottles, :meeting_id unless index_exists?(:bottles, :meeting_id)
    
    # Make bottle_bringer optional on meetings since flight nights might not have a single bringer
    change_column_null :meetings, :bottle_bringer_id, true
    
    # Add is_flight flag to meetings to distinguish flight nights from regular tastings
    add_column :meetings, :is_flight, :boolean, default: false, null: false
  end

  def down
    remove_column :meetings, :is_flight if column_exists?(:meetings, :is_flight)
    change_column_null :meetings, :bottle_bringer_id, false
    remove_index :bottles, :meeting_id if index_exists?(:bottles, :meeting_id)
    add_index :bottles, :meeting_id,
              unique: true,
              where: "meeting_id IS NOT NULL",
              name: "index_bottles_on_meeting_id_unique_when_present"
  end
end
