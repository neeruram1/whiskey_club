# Preview at http://localhost:3000/rails/mailers/meeting_mailer/scheduled
class MeetingMailerPreview < ActionMailer::Preview
  def scheduled
    meeting = Meeting.upcoming.first || Meeting.order(date: :desc).first
    member = User.first
    MeetingMailer.scheduled(meeting, member)
  end
end
