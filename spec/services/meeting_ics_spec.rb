require "rails_helper"

RSpec.describe MeetingIcs do
  let(:guide) { create(:user, first_name: "Ava", last_name: "Guide") }
  let(:url) { "https://collectivespirits.club/meetings/1" }

  def ics_for(meeting)
    described_class.new(meeting, location: "Dan's place", url: url).to_ics
  end

  it "wraps a single VEVENT with the club branding" do
    ics = ics_for(create(:meeting, bottle_bringer: guide))
    expect(ics).to include("BEGIN:VCALENDAR")
    expect(ics).to include("BEGIN:VEVENT")
    expect(ics).to include("END:VCALENDAR")
    expect(ics).to include("Collective Spirits")
  end

  it "includes the location and the guide in the summary" do
    ics = ics_for(create(:meeting, bottle_bringer: guide))
    expect(ics).to include("LOCATION:Dan's place")
    expect(ics).to include("SUMMARY:Whiskey Tasting — Ava Guide guides")
  end

  it "uses an all-day date event when no start time is set" do
    ics = ics_for(create(:meeting, date: Date.new(2026, 9, 12), start_time: nil))
    expect(ics).to include("DTSTART;VALUE=DATE:20260912")
    expect(ics).to include("DTEND;VALUE=DATE:20260913")
  end

  it "uses a timed event when a start time is set" do
    ics = ics_for(create(:meeting, date: Date.new(2026, 9, 12), start_time: "19:00"))
    expect(ics).to include("DTSTART:20260912T190000")
    expect(ics).to include("DTEND:20260912T210000")
  end

  it "calls it a flight night when there's no guide" do
    ics = ics_for(create(:meeting, :flight_night))
    expect(ics).to include("SUMMARY:Whiskey Flight Night — Collective Spirits")
  end

  it "escapes commas in the location" do
    ics = described_class.new(create(:meeting, bottle_bringer: guide), location: "Dan's place, Montclair", url: url).to_ics
    expect(ics).to include("LOCATION:Dan's place\\, Montclair")
  end
end
