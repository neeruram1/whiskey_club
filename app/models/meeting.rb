class Meeting < ApplicationRecord
  has_many :bottles, -> { order('LOWER(name)') }, dependent: :destroy
  belongs_to :bottle_bringer, class_name: 'User', optional: true
  has_many :meeting_attendees, dependent: :destroy
  has_many :attendees, through: :meeting_attendees, source: :user

  enum status: { scheduled: 0, started: 1, completed: 2 }

  validates :date, presence: true, uniqueness: true
  validates :bottle_bringer, presence: true, unless: :is_flight
  
  scope :upcoming, -> { where('date >= ?', Date.today).order(date: :asc) }
  scope :past_meetings, -> { where('date < ?', Date.today).order(date: :desc) }
  
  # Helper method to get primary bottle for regular tastings
  def bottle
    bottles.first
  end
  
  # Check if this is a flight night (multiple bottles)
  def flight_night?
    is_flight || bottles.loaded? && bottles.size > 1 || !bottles.loaded? && bottles.count > 1
  end

  def self.current
    upcoming.first
  end


  def meeting_status
    if date == Date.current
      :happening_today
    elsif date < Date.current
      :past
    else
      :upcoming
    end
  end
end
