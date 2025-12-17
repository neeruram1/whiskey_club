class AddNotesToMeetings < ActiveRecord::Migration[7.1]
  def change
    add_column :meetings, :notes, :text
  end
end
