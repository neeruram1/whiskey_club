class Rating < ApplicationRecord
  belongs_to :bottle, counter_cache: true
  belongs_to :user

  validates :score, presence: true, inclusion: { in: 0..5 }
  validates :comment, length: { maximum: 500 }
  validates :bottle_id, uniqueness: { scope: :user_id }

  # Update cached average rating on bottle when rating changes
  after_save :update_bottle_average
  after_destroy :update_bottle_average

  private

  def update_bottle_average
    bottle.update_cached_average_rating
  end
end
