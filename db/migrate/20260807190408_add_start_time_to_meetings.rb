class AddStartTimeToMeetings < ActiveRecord::Migration[7.1]
  def change
    add_column :meetings, :start_time, :time
  end
end
