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


  # Assumed start time for a tasting when none is set explicitly (7 PM).
  DEFAULT_START_HOUR = 19

  # Combines the tasting date with its optional start time into a single
  # zoned Time. Falls back to nil when no start time has been set.
  def starts_at
    return nil unless start_time

    Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min)
  end

  # The start time to use for calendar events — the explicit time when set,
  # otherwise the club's default hour, so calendar entries are never all-day.
  def calendar_starts_at
    starts_at || Time.zone.local(date.year, date.month, date.day, DEFAULT_START_HOUR)
  end

  # A short human label for the start time, e.g. "7:00 PM". Blank when unset.
  def start_time_label
    return nil unless start_time

    start_time.strftime("%-l:%M %p")
  end

  # Event title shared by every "add to calendar" target (.ics and Google).
  def calendar_title
    if flight_night?
      "Whiskey Flight Night — Collective Spirits"
    elsif bottle_bringer.present?
      "Whiskey Tasting — #{bottle_bringer.full_name} guides"
    else
      "Whiskey Tasting — Collective Spirits"
    end
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
