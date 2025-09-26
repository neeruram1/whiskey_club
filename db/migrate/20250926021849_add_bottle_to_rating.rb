class AddBottleToRating < ActiveRecord::Migration[7.1]
  def change
    add_reference :ratings, :bottle, null: false, foreign_key: true
  end
end
