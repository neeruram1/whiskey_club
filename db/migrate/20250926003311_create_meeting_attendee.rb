class CreateMeetingAttendee < ActiveRecord::Migration[7.1]
  def change
    create_table :meeting_attendees do |t|
      t.references :meeting, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :meeting_attendees, [:meeting_id, :user_id], unique: true
  end
end
