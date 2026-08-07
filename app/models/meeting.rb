class Meeting < ApplicationRecord
  has_many :bottles, -> { order('LOWER(name)') }, dependent: :destroy
  belongs_to :bottle_bringer, class_name: 'User', optional: true
  has_many :meeting_attendees, dependent: :destroy
  has_many :attendees, through: :meeting_attendees, source: :user

  enum status: { scheduled: 0, started: 1, completed: 2 }

  validates :date, presence: true, uniqueness: true
  validates :bottle_bringer, presence: true, unless: :is_flight
  
  scope :upcoming, -> { where('date >= ?', Time.zone.today).order(date: :asc) }
  scope :past_meetings, -> { where('date < ?', Time.zone.today).order(date: :desc) }
  
  # The single bottle for a regular tasting. Meaningful only for non-flight
  # meetings; flight nights have many bottles (see #flight_night?).
  def primary_bottle
    bottles.first
  end
  
  # Check if this is a flight night (multiple bottles)
  def flight_night?
    is_flight || bottles.loaded? && bottles.size > 1 || !bottles.loaded? && bottles.count > 1
  end

  def self.current
    upcoming.first
  end


  # Combines the tasting date with its optional start time into a single
  # zoned Time. Falls back to nil when no start time has been set.
  def starts_at
    return nil unless start_time

    Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min)
  end

  # A short human label for the start time, e.g. "7:00 PM". Blank when unset.
  def start_time_label
    return nil unless start_time

    start_time.strftime("%-l:%M %p")
  end

  def meeting_status
    if date == Time.zone.today
      :happening_today
    elsif date < Time.zone.today
      :past
    else
      :upcoming
    end
  end
end
