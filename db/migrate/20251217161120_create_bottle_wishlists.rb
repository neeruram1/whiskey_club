class CreateBottleWishlists < ActiveRecord::Migration[7.1]
  def change
    create_table :bottle_wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :bottle, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :bottle_wishlists, [:user_id, :bottle_id], unique: true
  end
end
