class Meeting < ApplicationRecord
  has_one :bottle, dependent: :destroy
  belongs_to :bottle_bringer, class_name: 'User'
  has_many :meeting_attendees, dependent: :destroy
  has_many :attendees, through: :meeting_attendees, source: :user

  enum status: { scheduled: 0, started: 1, completed: 2 }

  validates :date, presence: true
  scope :upcoming, -> { where('date >= ?', Date.today).order(date: :asc) }
  scope :past_meetings, -> { where('date < ?', Date.today).order(date: :desc) }

  def self.current
    upcoming.first
  end
end
