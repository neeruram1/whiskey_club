# Fan-out for meeting-related notifications.
class MeetingNotifier
  # Email every member that a tasting was scheduled, optionally skipping one
  # (typically whoever scheduled it).
  def self.scheduled(meeting, except: nil)
    User.where.not(id: except&.id).find_each do |member|
      MeetingMailer.scheduled(meeting, member).deliver_later
    end
  end
end
