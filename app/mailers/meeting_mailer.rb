class MeetingMailer < ApplicationMailer
  helper ApplicationHelper

  # Sent to each member when a new tasting is scheduled.
  def scheduled(meeting, member)
    @meeting = meeting
    @member = member
    @guide = meeting.bottle_bringer

    mail(
      to: member.email,
      subject: "New tasting scheduled — #{meeting.date.strftime('%A, %B %-d')}"
    )
  end
end
