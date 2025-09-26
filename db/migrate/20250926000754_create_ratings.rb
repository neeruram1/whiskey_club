class CreateRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :ratings do |t|
      t.integer :score, null: false, default: 0
      t.text :comment, limit: 500
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
