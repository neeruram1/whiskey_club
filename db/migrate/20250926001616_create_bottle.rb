class CreateBottle < ActiveRecord::Migration[7.1]
  def change
    create_table :bottles do |t|
      t.string :name, null: false
      t.string :distillery, null: false
      t.integer :age
      t.decimal :final_score, precision: 3, scale: 1
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
