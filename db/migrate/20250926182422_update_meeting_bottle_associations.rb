class UpdateMeetingBottleAssociations < ActiveRecord::Migration[7.1]
  def up
    add_column :bottles, :revealed_at, :datetime
    add_column :meetings, :status, :integer, default: 0, null: false
    change_column_null :meetings, :bottle_bringer_id, false
    remove_reference :meetings, :bottle, foreign_key: true
    remove_index :bottles, :meeting_id if index_exists?(:bottles, :meeting_id)
    add_index :bottles, :meeting_id,
              unique: true,
              where: "meeting_id IS NOT NULL",
              name: "index_bottles_on_meeting_id_unique_when_present"
  end

  def down
    remove_index :bottles, name: "index_bottles_on_meeting_id_unique_when_present" if index_exists?(:bottles, name: "index_bottles_on_meeting_id_unique_when_present")
    add_index :bottles, :meeting_id unless index_exists?(:bottles, :meeting_id)
    add_reference :meetings, :bottle, foreign_key: true
    change_column_null :meetings, :bottle_bringer_id, true
    remove_column :meetings, :status if column_exists?(:meetings, :status)
    remove_column :bottles, :revealed_at if column_exists?(:bottles, :revealed_at)
  end
end
