class MeetingAttendee < ApplicationRecord
  belongs_to :meeting, counter_cache: :attendees_count
  belongs_to :user

  validates :meeting_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :meeting_id }
end
