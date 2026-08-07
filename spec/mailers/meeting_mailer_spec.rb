require "rails_helper"

RSpec.describe MeetingMailer, type: :mailer do
  describe "#scheduled" do
    let(:guide) { create(:user, first_name: "Ava", last_name: "Guide") }
    let(:member) { create(:user, email: "member@example.com") }
    let(:meeting) { create(:meeting, bottle_bringer: guide, date: Date.new(2026, 9, 12)) }
    let(:mail) { described_class.scheduled(meeting, member) }

    it "is addressed to the member" do
      expect(mail.to).to eq(["member@example.com"])
    end

    it "has a subject naming the tasting date" do
      expect(mail.subject).to include("New tasting scheduled")
      expect(mail.subject).to include("September 12")
    end

    it "names the spirit guide and links to the tasting" do
      body = mail.body.encoded
      expect(body).to include("Ava Guide")
      expect(body).to include("/meetings/#{meeting.id}")
    end

    it "calls it a flight night when there's no bringer" do
      flight = create(:meeting, :flight_night)
      body = described_class.scheduled(flight, member).body.encoded
      expect(body).to match(/Flight Night/i)
    end
  end
end
