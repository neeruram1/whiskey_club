class AddCachedAverageRatingToBottles < ActiveRecord::Migration[7.1]
  def change
    add_column :bottles, :cached_average_rating, :decimal, precision: 3, scale: 2
    add_index :bottles, :cached_average_rating
    
    # Backfill existing data
    reversible do |dir|
      dir.up do
        Bottle.find_each do |bottle|
          avg = bottle.ratings.average(:score)
          bottle.update_column(:cached_average_rating, avg) if avg
        end
      end
    end
  end
end
