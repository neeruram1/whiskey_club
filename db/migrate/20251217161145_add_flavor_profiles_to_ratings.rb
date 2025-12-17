class AddFlavorProfilesToRatings < ActiveRecord::Migration[7.1]
  def change
    add_column :ratings, :flavors, :text
  end
end
