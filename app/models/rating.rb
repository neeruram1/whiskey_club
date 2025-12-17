class Rating < ApplicationRecord
  belongs_to :bottle, counter_cache: true
  belongs_to :user

  validates :score, presence: true, inclusion: { in: 0..5 }
  validates :comment, length: { maximum: 500 }
  validates :bottle_id, uniqueness: { scope: :user_id }

  # Serialize flavors as array
  serialize :flavors, type: Array, coder: JSON

  # Available flavor options
  FLAVORS = %w[
    Smoky Peaty Fruity Spicy Sweet Oaky Floral Nutty
    Vanilla Caramel Citrus Herbal Honey Chocolate Leather
    Tropical Earthy Maritime Medicinal
  ].freeze

  # Update cached average rating on bottle when rating changes
  after_save :update_bottle_average
  after_destroy :update_bottle_average
  
  # Automatically mark user as attended when they rate a bottle
  after_save :mark_meeting_attendance

  private

  def update_bottle_average
    bottle.update_cached_average_rating
  end
  
  def mark_meeting_attendance
    meeting = bottle.meeting
    return unless meeting
    
    # Create attendance record if it doesn't exist
    meeting.meeting_attendees.find_or_create_by(user: user)
  end
end
