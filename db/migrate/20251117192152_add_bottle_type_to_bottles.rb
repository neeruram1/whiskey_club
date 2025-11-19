class AddBottleTypeToBottles < ActiveRecord::Migration[7.1]
  def change
    add_column :bottles, :bottle_type, :string
  end
end
