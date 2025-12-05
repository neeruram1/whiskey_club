class ChangeRatingScoreToDecimal < ActiveRecord::Migration[7.1]
  def change
    change_column :ratings, :score, :decimal, precision: 5, scale: 3, default: 0.0, null: false
  end
end
