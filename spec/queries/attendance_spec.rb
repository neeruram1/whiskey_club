require 'rails_helper'

RSpec.describe Attendance do
  let(:member) { create(:user) }

  describe '#rate' do
    it 'is the percentage of past meetings the member attended' do
      attended = create(:meeting, date: 1.week.ago)
      _missed = create(:meeting, date: 2.weeks.ago)
      create(:meeting_attendee, user: member, meeting: attended)

      described = described_class.new(member)
      expect(described.total_past_meetings).to eq(2)
      expect(described.meetings_attended).to eq(1)
      expect(described.rate).to eq(50)
    end

    it 'ignores meetings that have not happened yet' do
      upcoming = create(:meeting, date: 1.week.from_now)
      create(:meeting_attendee, user: member, meeting: upcoming)

      expect(described_class.new(member).total_past_meetings).to eq(0)
    end

    it 'is 0 when there are no past meetings' do
      expect(described_class.new(member).rate).to eq(0)
    end
  end
end
