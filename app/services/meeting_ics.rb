# Builds an RFC 5545 iCalendar (.ics) document for a single tasting so members
# can add it to their own calendar. The event is a timed three-hour pour,
# defaulting to the club's usual start hour when no time is set.
class MeetingIcs
  DURATION = 3.hours

  def initialize(meeting, location:, url:)
    @meeting = meeting
    @location = location
    @url = url
  end

  def filename
    "tasting-#{@meeting.date.strftime('%Y-%m-%d')}.ics"
  end

  def to_ics
    lines = [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:-//Collective Spirits of Montclair//Tasting//EN",
      "CALSCALE:GREGORIAN",
      "BEGIN:VEVENT",
      "UID:tasting-#{@meeting.id}@collectivespirits.club",
      "DTSTAMP:#{Time.now.utc.strftime('%Y%m%dT%H%M%SZ')}",
      *dtstart_dtend,
      "SUMMARY:#{escape(@meeting.calendar_title)}",
      "LOCATION:#{escape(@location)}",
      "DESCRIPTION:#{escape(description)}",
      "URL:#{@url}",
      "END:VEVENT",
      "END:VCALENDAR"
    ]
    "#{lines.join("\r\n")}\r\n"
  end

  private

  def dtstart_dtend
    start = @meeting.calendar_starts_at
    ["DTSTART:#{start.strftime('%Y%m%dT%H%M%S')}",
     "DTEND:#{(start + DURATION).strftime('%Y%m%dT%H%M%S')}"]
  end

  def description
    "The bottle stays sealed until the reveal. Details: #{@url}"
  end

  def escape(value)
    value.to_s
         .gsub("\\", "\\\\\\\\")
         .gsub(",", "\\,")
         .gsub(";", "\\;")
         .gsub("\n", "\\n")
  end
end
