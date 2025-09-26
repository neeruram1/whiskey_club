class CreateMeeting < ActiveRecord::Migration[7.1]
  def change
    create_table :meetings do |t|
      t.date :date, null: false
      t.references :bottle, foreign_key: true, null: true
      t.references :bottle_bringer, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
