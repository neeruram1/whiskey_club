# A member's attendance record across meetings that have already happened.
class Attendance
  def initialize(user)
    @user = user
  end

  def total_past_meetings
    @total_past_meetings ||= Meeting.past_meetings.count
  end

  def meetings_attended
    @meetings_attended ||= @user.meetings.where(date: ...Time.zone.today).count
  end

  # Percentage of past meetings this member attended, rounded to a whole number.
  def rate
    return 0 if total_past_meetings.zero?

    ((meetings_attended.to_f / total_past_meetings) * 100).round
  end
end
