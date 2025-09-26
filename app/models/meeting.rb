class Meeting < ApplicationRecord
  has_one :bottle, dependent: :destroy
  has_one :bottle_bringer, through: :bottle, source: :user
  has_many :meeting_attendees, dependent: :destroy
  has_many :attendees, through: :meeting_attendees, source: :user

  validates :date, presence: true
end
