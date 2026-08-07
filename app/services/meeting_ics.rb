# Builds an RFC 5545 iCalendar (.ics) document for a single tasting so members
# can add it to their own calendar. When the meeting has a start time the event
# is timed (defaulting to a two-hour pour); otherwise it's an all-day event.
class MeetingIcs
  DURATION = 2.hours

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
      "SUMMARY:#{escape(summary)}",
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
    if (start = @meeting.starts_at)
      ["DTSTART:#{start.strftime('%Y%m%dT%H%M%S')}",
       "DTEND:#{(start + DURATION).strftime('%Y%m%dT%H%M%S')}"]
    else
      ["DTSTART;VALUE=DATE:#{@meeting.date.strftime('%Y%m%d')}",
       "DTEND;VALUE=DATE:#{(@meeting.date + 1).strftime('%Y%m%d')}"]
    end
  end

  def summary
    if @meeting.flight_night?
      "Whiskey Flight Night — Collective Spirits"
    elsif @meeting.bottle_bringer.present?
      "Whiskey Tasting — #{@meeting.bottle_bringer.full_name} guides"
    else
      "Whiskey Tasting — Collective Spirits"
    end
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
