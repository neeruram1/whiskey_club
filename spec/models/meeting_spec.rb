require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:date) }
    it { should validate_uniqueness_of(:date) }
    
    context 'bottle_bringer validation' do
      it 'requires bottle_bringer for regular tastings' do
        meeting = build(:meeting, bottle_bringer: nil, is_flight: false)
        expect(meeting).not_to be_valid
        expect(meeting.errors[:bottle_bringer]).to include("can't be blank")
      end
      
      it 'does not require bottle_bringer for flight nights' do
        meeting = build(:meeting, bottle_bringer: nil, is_flight: true)
        expect(meeting).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should have_many(:bottles).dependent(:destroy) }
    it { should belong_to(:bottle_bringer).class_name('User').optional }
    it { should have_many(:meeting_attendees).dependent(:destroy) }
    it { should have_many(:attendees).through(:meeting_attendees).source(:user) }
  end

  describe 'scopes' do
    let!(:past_meeting) { create(:meeting, date: 1.week.ago) }
    let!(:today_meeting) { create(:meeting, date: Date.current) }
    let!(:future_meeting) { create(:meeting, date: 1.week.from_now) }

    describe '.upcoming' do
      it 'returns meetings today and in the future' do
        expect(Meeting.upcoming).to include(today_meeting, future_meeting)
        expect(Meeting.upcoming).not_to include(past_meeting)
      end

      it 'orders by date ascending' do
        expect(Meeting.upcoming.first).to eq(today_meeting)
        expect(Meeting.upcoming.last).to eq(future_meeting)
      end
    end

    describe '.past_meetings' do
      it 'returns only past meetings' do
        expect(Meeting.past_meetings).to include(past_meeting)
        expect(Meeting.past_meetings).not_to include(today_meeting, future_meeting)
      end

      it 'orders by date descending' do
        older_meeting = create(:meeting, date: 2.weeks.ago)
        expect(Meeting.past_meetings.first).to eq(past_meeting)
        expect(Meeting.past_meetings.last).to eq(older_meeting)
      end
    end
  end

  describe '.current' do
    it 'returns the next upcoming meeting' do
      create(:meeting, date: 2.weeks.from_now)
      next_meeting = create(:meeting, date: 1.week.from_now)
      expect(Meeting.current).to eq(next_meeting)
    end

    it 'returns nil if no upcoming meetings' do
      create(:meeting, date: 1.week.ago)
      expect(Meeting.current).to be_nil
    end
  end

  describe '#bottle' do
    let(:meeting) { create(:meeting) }
    let!(:first_bottle) { create(:bottle, meeting: meeting, created_at: 1.day.ago) }
    let!(:second_bottle) { create(:bottle, meeting: meeting, created_at: 1.hour.ago) }

    it 'returns the first bottle' do
      expect(meeting.bottle).to eq(first_bottle)
    end
  end

  describe '#flight_night?' do
    context 'when is_flight is true' do
      let(:meeting) { create(:meeting, is_flight: true) }

      it 'returns true' do
        expect(meeting.flight_night?).to be true
      end
    end

    context 'when has multiple bottles' do
      let(:meeting) { create(:meeting, is_flight: false) }

      before do
        create_list(:bottle, 2, meeting: meeting)
        meeting.reload
      end

      it 'returns true' do
        expect(meeting.flight_night?).to be true
      end
    end

    context 'when is regular tasting' do
      let(:meeting) { create(:meeting, is_flight: false) }

      before do
        create(:bottle, meeting: meeting)
        meeting.reload
      end

      it 'returns false' do
        expect(meeting.flight_night?).to be false
      end
    end
  end

  describe '#meeting_status' do
    it 'returns :happening_today for today\'s meeting' do
      meeting = create(:meeting, date: Date.current)
      expect(meeting.meeting_status).to eq(:happening_today)
    end

    it 'returns :past for past meetings' do
      meeting = create(:meeting, date: 1.week.ago)
      expect(meeting.meeting_status).to eq(:past)
    end

    it 'returns :upcoming for future meetings' do
      meeting = create(:meeting, date: 1.week.from_now)
      expect(meeting.meeting_status).to eq(:upcoming)
    end
  end
end
