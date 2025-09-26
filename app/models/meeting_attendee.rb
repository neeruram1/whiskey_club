class MeetingAttendee < ApplicationRecord
  belongs_to :meeting
  belongs_to :user

  validates :meeting_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :meeting_id }
end
